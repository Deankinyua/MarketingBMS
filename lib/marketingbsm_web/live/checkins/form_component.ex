defmodule MarketingbsmWeb.CheckinLive.FormComponent do
  use MarketingbsmWeb, :live_component

  alias SimpleS3Upload
  require Ash.Query

  alias Marketingbsm.File
  alias AshPhoenix.Form
  alias Marketingbsm.Accounts
  alias Marketingbsm.Clockin

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
          Use this form for check-in
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
              <.live_file_input
                type="file"
                upload={@uploads.checkinphoto}
                class="hidden pointer-events-none"
                capture="environment"
              />
            </fieldset>

            <.droptarget
              for={@uploads.checkinphoto.ref}
              on_click={JS.dispatch("click", to: "##{@uploads.checkinphoto.ref}", bubbles: false)}
              drop_target_ref={@uploads.checkinphoto.ref}
            />

            <%= for entry <- @uploads.checkinphoto.entries
    do %>
              <article class="upload-entry">
                <figure>
                  <.live_img_preview entry={entry} height="40" />
                </figure>

                <Layout.flex justify_content="start" align_items="center" class="space-x-4">
                  <Layout.flex
                    justify_content="center"
                    class="w-16 h-16 bg-tremor-brand text-white rounded-md flex-shrink-0"
                  >
                    <.icon name="hero-camera" class="h-6 w-6" />
                  </Layout.flex>

                  <Layout.flex flex_direction="col" align_items="start">
                    <Layout.flex class="space-x-4">
                      <Layout.flex class="" flex_direction="col" align_items="start">
                        <div class="w-full flex-1">
                          <Text.subtitle color="black" class="text-ellipsis">
                            <%= entry.client_name %>
                          </Text.subtitle>
                        </div>
                      </Layout.flex>

                      <Button.button
                        class="mt-2 flex-shrink-0"
                        variant="secondary"
                        color="rose"
                        size="xs"
                        phx-click="cancel-upload"
                        phx-value-ref={entry.ref}
                        aria-label="cancel"
                        phx-target={@myself}
                      >
                        Cancel
                      </Button.button>
                    </Layout.flex>

                    <Bar.progress_bar
                      :if={entry.progress > 0}
                      class="mt-3"
                      value={entry.progress}
                      show_animation={true}
                    />
                  </Layout.flex>
                </Layout.flex>

                <%= for err <- upload_errors(@uploads.checkinphoto, entry) do %>
                  <p class="alert alert-danger"><%= error_to_string(err) %></p>
                <% end %>
              </article>
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
      |> allow_upload(:checkinphoto,
        accept: ~w(.png .jpg .jpeg),
        max_entries: 1,
        id: "image_file",
        max_file_size: 80_000_000,
        external: fn entry, socket ->
          SimpleS3Upload.presign_upload(entry, socket, "checkinphoto")
        end
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
  def handle_event("cancel-upload", %{"ref" => ref, "value" => _value}, socket) do
    {:noreply, cancel_upload(socket, :checkinphoto, ref)}
  end

  @impl true
  def handle_event("validate", %{"checkin" => checkin_params}, socket) do
    form = socket.assigns.form |> Form.validate(checkin_params, errors: false)

    {:noreply, assign(socket, form: form)}

    # {:noreply, socket}
  end

  def handle_event("save", %{"checkin" => checkin_params}, socket) do
    ambassador_id = RegistryComponent.get_ambassador_id(socket, checkin_params)

    date = Date.utc_today()

    case Clockin.verify_checkin(ambassador_id, date) do
      {:ok, _record} ->
        {:noreply,
         socket
         |> put_flash(:error, "You have already checked in !!")
         |> push_patch(to: "/checkins")}

      {:error, _error} ->
        outlet_id = RegistryComponent.get_outlet_id(socket, checkin_params)
        project_id = RegistryComponent.get_project_id(socket, checkin_params)

        checkin_params =
          Map.merge(checkin_params, %{
            "ambassador_id" => ambassador_id,
            "project_id" => project_id,
            "outlet_id" => outlet_id
          })

        consume_uploaded_entries(socket, :checkinphoto, fn _meta, entry ->
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
            checkin_params = Map.merge(checkin_params, %{"file" => file})
            form = socket.assigns.form |> Form.validate(checkin_params)

            Form.errors(form)
            |> case do
              [] ->
                submit_form(socket, checkin_params, file)

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
  end

  # defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

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

  defp submit_form(socket, params, _file) do
    dbg(params)
    # params = Map.merge(params, %{file: file})

    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _checkin} ->
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
          |> push_patch(to: "/checkins")

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

  attr :on_click, JS, required: true
  attr :drop_target_ref, :string, required: true
  attr :for, :string, required: true

  @doc """
  Renders a drop target to upload files
  """

  def droptarget(assigns) do
    ~H"""
    <div
      phx-click={@on_click}
      phx-drop-target={@drop_target_ref}
      for={@for}
      class="flex flex-col items-center max-w-2xl w-full py-8 px-6 mx-auto mt-2 text-center border-2 border-gray-300 border-dashed cursor-pointer dark:bg-gray-900 dark:border-gray-700 rounded-md"
    >
      <.icon name="hero-camera" class="w-8 h-8 mb-4 text-gray-500 dark:text-gray-400" />
      <Text.title>
        Take Your Photo
      </Text.title>
    </div>
    """
  end
end
