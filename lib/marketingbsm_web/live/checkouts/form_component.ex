defmodule MarketingbsmWeb.CheckoutLive.FormComponent do
  use MarketingbsmWeb, :live_component

  alias SimpleS3Upload
  require Ash.Query

  alias Marketingbsm.ProjectGeneral
  alias Marketingbsm.File
  alias Marketingbsm.Clockin
  alias Marketingbsm.Record
  alias AshPhoenix.Form

  alias MarketingbsmWeb.CheckinLive.FormComponent, as: CheckinComponent
  alias MarketingbsmWeb.ReportLive.FormComponent

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <Text.title class="text-xl">
          <Text.bold><%= @title %></Text.bold>
        </Text.title>

        <Text.subtitle color="gray">
          Use this form for check-out.
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

            <fieldset>
              <.live_file_input
                type="file"
                upload={@uploads.checkoutphoto}
                class="hidden pointer-events-none"
                capture="environment"
              />
            </fieldset>

            <CheckinComponent.droptarget
              for={@uploads.checkoutphoto.ref}
              on_click={JS.dispatch("click", to: "##{@uploads.checkoutphoto.ref}", bubbles: false)}
              drop_target_ref={@uploads.checkoutphoto.ref}
            />

            <%= for entry <- @uploads.checkoutphoto.entries
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

                <%= for err <- upload_errors(@uploads.checkoutphoto, entry) do %>
                  <p class="alert alert-danger"><%= error_to_string(err) %></p>
                <% end %>
              </article>
            <% end %>

            <Button.button type="submit" size="xl" class="mt-2 w-min" phx-disable-with="Submitting...">
              Submit Check-Out
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
      |> allow_upload(:checkoutphoto,
        accept: ~w(.png .jpg .jpeg),
        max_entries: 1,
        id: "image_file",
        max_file_size: 80_000_000,
        external: fn entry, socket ->
          SimpleS3Upload.presign_upload(entry, socket, "checkoutphoto")
        end
      )

    {:ok,
     socket
     |> assign(assigns)
     |> FormComponent.fetch_projects_unfreezed()
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"checkout" => checkout_params}, socket) do
    form = socket.assigns.form |> Form.validate(checkout_params, errors: false)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"checkout" => checkout_params}, socket) do
    id = socket.assigns.current_user

    case Record.get_user_by_id(id) do
      {:ok, registry} ->
        ambassador_id = registry.ambassador_id
        outlet_id = registry.outlet_id
        project_id = registry.project_id

        actual_project = ProjectGeneral.get_project_by_id!(project_id)

        if actual_project.is_freezed == true do
          {:noreply,
           socket
           |> put_flash(:error, "The Project You are activating is Freezed!!")
           |> push_patch(to: "/checkins")}
        else
          date = Date.utc_today()

          case Clockin.get_user_by_id(ambassador_id, date) do
            {:ok, _record} ->
              {:noreply,
               socket
               |> put_flash(:error, "You have already checked Out !!")
               |> push_patch(to: "/checkouts")}

            {:error, _error} ->
              checkout_params =
                Map.merge(checkout_params, %{
                  "ambassador_id" => ambassador_id,
                  "project_id" => project_id,
                  "outlet_id" => outlet_id
                })

              consume_uploaded_entries(socket, :checkoutphoto, fn _meta, entry ->
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

                  case Form.errors(form) do
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
        end

      {:error, _error} ->
        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)
         |> put_flash(:error, "Report Not Submitted!! You are not scheduled to activate")}
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
end
