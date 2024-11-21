defmodule MarketingbsmWeb.CheckoutLive.FormComponent do
  use MarketingbsmWeb, :live_component

  alias SimpleS3Upload
  require Ash.Query

  alias Marketingbsm.File
  alias AshPhoenix.Form
  alias Marketingbsm.Accounts

  alias MarketingbsmWeb.ReportLive.FormComponent
  alias MarketingbsmWeb.RegistryLive.FormComponent, as: RegistryComponent

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <Text.title class="text-xl">
          <Text.bold><%= @title %></Text.bold>
        </Text.title>

        <Text.subtitle color="gray">
          Use this form for checkin .
        </Text.subtitle>

        <Layout.divider class="my-4" />

        <Layout.col>
          <.form :let={f} for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
            <Layout.col class="space-y-1.5">
              <label>
                <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                  Project Name
                </Text.text>
              </label>

              <Select.select
                id="project[:project_id]"
                name={f[:project_id].name}
                placeholder="Select..."
                value={@form[:project_id].value}
                phx-update="ignore"
              >
                <:item :for={%{id: _id, name: name} <- @projects}>
                  <%= name %>
                </:item>
              </Select.select>
            </Layout.col>

            <Layout.col class="space-y-1.5">
              <label>
                <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                  Ambassador Name
                </Text.text>
              </label>

              <Select.search_select
                id="ambassador[:ambassador_id]"
                name={@form[:ambassador_id].name}
                placeholder="Select..."
                value={@form[:ambassador_id].value}
                phx-update="ignore"
                required={true}
              >
                <:item :for={%{id: _id, name: name} <- @ambassadors}>
                  <%= name %>
                </:item>
              </Select.search_select>
            </Layout.col>

            <Layout.col class="space-y-1.5">
              <label>
                <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                  Outlet Name
                </Text.text>
              </label>

              <Select.search_select
                id="outlet[:outlet_id]"
                name={@form[:outlet_id].name}
                placeholder="Select..."
                value={@form[:outlet_id].value}
                phx-update="ignore"
              >
                <:item :for={%{id: _id, name: name} <- @outlets}>
                  <%= name %>
                </:item>
              </Select.search_select>
            </Layout.col>

            <fieldset>
              <.live_file_input type="file" upload={@uploads.photo} />
            </fieldset>

            <%= for entry <- @uploads.photo.entries
    do %>
              <article class="upload-entry">
                <figure>
                  <.live_img_preview entry={entry} height="40" />
                  <figcaption><%= entry.client_name %></figcaption>
                </figure>

                <progress value="{entry.progress}" max="100">
                  <%= entry.progress %>%
                </progress>

                <button
                  type="button"
                  phx-click="cancel-upload"
                  phx-value-ref={entry.ref}
                  aria-label="cancel"
                >
                  cancel
                </button>

                <%= for err <- upload_errors(@uploads.photo, entry) do %>
                  <p class="alert alert-danger"><%= error_to_string(err) %></p>
                <% end %>
              </article>
            <% end %>

            <%= for err <- upload_errors(@uploads.photo) do %>
              <p class="alert alert-danger"><%= error_to_string(err) %></p>
            <% end %>
            <Button.button type="submit" size="xl" class="mt-2 w-min" phx-disable-with="Submitting...">
              Submit Check-In
            </Button.button>
          </.form>
        </Layout.col>
      </Layout.col>
    </section>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:photo,
        accept: ~w(.png .jpg .jpeg),
        max_entries: 1,
        id: "image_file",
        max_file_size: 80_000_000,
        external: fn entry, socket -> SimpleS3Upload.presign_upload(entry, socket, "photo") end
      )

    {:ok,
     socket
     |> assign(assigns)
     |> fetch_promoters()
     |> FormComponent.fetch_projects_unfreezed()
     |> fetch_outlets()
     |> assign_form()}
  end

  def fetch_promoters(socket) do
    query_results =
      Marketingbsm.Record.Registry
      |> Ash.Query.filter(should_activate: true)
      |> Ash.Query.load([])
      |> Ash.read!(page: [limit: 20])

    ambassadors = Map.get(query_results, :results)

    socket |> assign(ambassadors: ambassador_selector(ambassadors))
  end

  def fetch_outlets(socket) do
    query_results =
      Marketingbsm.Outlet.Shop
      |> Ash.Query.load([])
      |> Ash.Query.sort(created_at: :desc)
      |> Ash.read!(page: [limit: 20])

    outlets = Map.get(query_results, :results)

    socket |> assign(outlets: outlets)
  end

  @impl true
  def handle_event("validate", %{"checkout" => checkout_params}, socket) do
    form = socket.assigns.form |> Form.validate(checkout_params, errors: false)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"checkout" => checkout_params}, socket) do
    ambassador_id = RegistryComponent.get_ambassador_id(socket, checkout_params)
    outlet_id = RegistryComponent.get_outlet_id(socket, checkout_params)
    project_id = RegistryComponent.get_project_id(socket, checkout_params)

    checkout_params =
      Map.merge(checkout_params, %{
        "ambassador_id" => ambassador_id,
        "project_id" => project_id,
        "outlet_id" => outlet_id
      })

    consume_uploaded_entries(socket, :photo, fn _meta, entry ->
      client_name = Map.get(entry, :client_name)
      filename = Map.get(entry, :uuid) <> "." <> SimpleS3Upload.ext(entry)

      {:ok,
       %File{
         filename: filename,
         original_filename: client_name
       }}
    end)
    |> case do
      [] ->
        socket =
          socket
          |> assign(:audio_errors, %{filename: "is required"})

        send_update(__MODULE__,
          id: socket.assigns.form_name,
          update: :toggle_submit,
          value: false
        )

        {:noreply, socket}

      [%File{} = file] ->
        checkout_params = Map.merge(checkout_params, %{"file" => file})
        form = socket.assigns.form |> Form.validate(checkout_params)

        Form.errors(form)
        |> case do
          [] ->
            submit_form(socket, checkout_params, file)

          errors ->
            send_update(__MODULE__,
              id: socket.assigns.form_name,
              update: :toggle_submit,
              value: false
            )

            socket =
              socket
              |> assign(:form, form)
              |> assign(:errors, errors)

            {:noreply, socket}
        end
    end
  end

  # defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(socket) do
    form =
      AshPhoenix.Form.for_create(Marketingbsm.Clockin.Checkout, :create,
        as: "checkout",
        actor: socket.assigns.current_user
      )

    assign(socket, form: to_form(form))
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:external_client_failure), do: "External client failure "

  defp submit_form(socket, params, _file) do
    # params = Map.merge(params, %{file: file})

    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _checkout} ->
        Process.send_after(
          self(),
          %{
            event: "notification",
            title: "Success",
            message: "Your Audio file has been uploaded and is being currently reviewed",
            type: "success"
          },
          1000
        )

        socket =
          socket
          |> put_flash(:info, "Your Photo has Been received")
          |> push_patch(to: "/checkouts")

        {:noreply,
         socket
         |> assign_form()
         |> assign(:uploaded_files, [])
         |> assign(:audio_errors, nil)}

      {:error, form} ->
        Process.send_after(
          self(),
          %{
            event: "notification",
            title: "An Error Occurred",
            message: "Something went wrong when uploading. Try again",
            type: "error"
          },
          300
        )

        {:noreply, assign(socket, form: form)}
    end
  end

  def ambassador_selector(ambassadors) do
    for item <- ambassadors do
      user = Accounts.get_user_by_id!(item.ambassador_id)

      user
    end
  end
end
