defmodule MarketingbsmWeb.CheckinLive.FormComponent do
  use MarketingbsmWeb, :live_component

  alias SimpleS3Upload

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
                name={@form[:project_id].name}
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

            <section phx-drop-target="{@uploads.photo.ref}">
              <.live_file_input upload={@uploads.photo} id="fileInput" />

              <%= for entry <- @uploads.photo.entries
    do %>
                <article class="upload-entry">
                  <figure>
                    <.live_img_preview entry={entry} , height: 40 />
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
            </section>
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
        max_file_size: 80_000_000,
        external: fn entry, socket -> presign_entry(entry, socket) end
      )

    {:ok,
     socket
     |> assign(assigns)
     |> FormComponent.fetch_promoters()
     |> FormComponent.fetch_projects_unfreezed()
     |> FormComponent.fetch_outlets()
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"checkin" => checkin_params}, socket) do
    dbg(checkin_params)
    {:noreply, socket}
  end

  def handle_event("save", %{"checkin" => checkin_params}, socket) do
    # consume_uploaded_entries(socket, :photo, fn _meta, entry ->
    #   {:ok, entry}
    # end)
    dbg(checkin_params)

    ambassador_id = RegistryComponent.get_ambassador_id(socket, checkin_params)
    outlet_id = RegistryComponent.get_outlet_id(socket, checkin_params)
    project_id = RegistryComponent.get_project_id(socket, checkin_params)

    checkin_params =
      Map.merge(checkin_params, %{
        "ambassador_id" => ambassador_id,
        "project_id" => project_id,
        "outlet_id" => outlet_id
      })

    case AshPhoenix.Form.submit(socket.assigns.form, params: checkin_params) do
      {:ok, report} ->
        notify_parent({:saved, report})

        socket =
          socket
          |> put_flash(:info, "Your Check-In has been received successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(socket) do
    form =
      AshPhoenix.Form.for_create(Marketingbsm.Clockin.Checkin, :create,
        as: "checkin",
        actor: socket.assigns.current_user
      )

    assign(socket, form: to_form(form))
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:external_client_failure), do: "External client failure "

  def ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end

  @bucket "deanbucketkenya"
  @region "eu-north-1"

  defp s3_host, do: "http://#{@bucket}.s3.amazonaws.com"
  defp s3_key(entry), do: "#{entry.uuid}.#{ext(entry)}"

  defp presign_entry(entry, socket) do
    uploads = socket.assigns.uploads

    dbg(uploads)

    bucket = "deanbucketkenya"

    key = s3_key(entry)

    config = %{
      region: "eu-north-1",
      access_key_id: System.fetch_env!("S3_ACCESS_KEY_ID"),
      secret_access_key: System.fetch_env!("S3_SECRET_ACCESS_KEY")
    }

    {:ok, fields} =
      SimpleS3Upload.sign_form_upload(config, @bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: uploads.photo.max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{
      uploader: "S3",
      key: key,
      url: "http://#{bucket}.s3-#{config.region}.amazonaws.com",
      fields: fields
    }

    {:ok, meta, socket}
  end

  def put_photo_urls(socket) do
    {completed, []} = uploaded_entries(socket, :photo)

    url =
      for entry <- completed do
        Path.join(s3_host(), s3_key(entry))
      end

    url = Enum.at(url, 0)
    url
  end
end
