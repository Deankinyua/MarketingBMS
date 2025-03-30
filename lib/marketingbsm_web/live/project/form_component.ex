defmodule MarketingbsmWeb.ProjectLive.FormComponent do
  use MarketingbsmWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <Text.title class="text-xl">
          <Text.bold>{@title}</Text.bold>
        </Text.title>

        <Text.subtitle color="gray">
          Use this form to manage Project records in your database.
        </Text.subtitle>

        <Layout.divider class="my-4" />

        <.form :let={f} for={@form} phx-target={@myself} phx-submit="save">
          <%= if @form.source.type == :create do %>
            <Layout.col class="space-y-1.5">
              <label for="name_field">
                <Text.text class="text-tremor-content">
                  Project Name
                </Text.text>
              </label>

              <Input.text_input
                id="name"
                name={f[:name].name}
                placeholder="Project Name..."
                type="text"
                field={f[:name]}
                value={f[:name].value}
                required="true"
              />
            </Layout.col>
          <% end %>

          <%= if @form.source.type == :update do %>
            <Layout.col class="space-y-1.5">
              <label for="name">
                <Text.text class="text-tremor-content">
                  Project Name
                </Text.text>
              </label>

              <Input.text_input
                id="name"
                name={@form[:name].name}
                placeholder="New Name..."
                type="text"
                field={@form[:name]}
                value={@form[:name].value}
                required="true"
              />
              <Layout.col class="space-y-1.5">
                <label for="status">
                  <Text.text class="text-tremor-content">
                    Freezed Status
                  </Text.text>
                </label>

                <.input
                  id="status"
                  field={@form[:is_freezed]}
                  type="select"
                  options={@freeze_selector}
                />
              </Layout.col>
            </Layout.col>
          <% end %>

          <Button.button type="submit" size="xl" class="mt-2 w-min" phx-disable-with="Saving...">
            <%= if @form.source.type == :update do %>
              Update Project
            <% else %>
              Create New Project
            <% end %>
          </Button.button>
        </.form>
      </Layout.col>
    </section>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> freeze_selector()
     |> assign_form()}
  end

  defp freeze_selector(socket) do
    socket |> assign(freeze_selector: ["Yes", "No"])
  end

  @impl true
  def handle_event("save", %{"project" => project_params}, socket) do
    freeze_status = project_params["is_freezed"]
    freeze_status = return_status(freeze_status)

    project_params =
      Map.merge(project_params, %{
        "is_freezed" => freeze_status
      })

    case AshPhoenix.Form.submit(socket.assigns.form, params: project_params) do
      {:ok, project} ->
        notify_parent({:saved, project})

        socket =
          socket
          |> put_flash(:info, "Project #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, _form} ->
        {:noreply,
         socket
         |> put_flash(:error, "You are not authorized to perform this action")
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{project: project}} = socket) do
    form =
      if project do
        AshPhoenix.Form.for_update(project, :update_project,
          as: "project",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Marketingbsm.ProjectGeneral.Project, :new,
          as: "project",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def return_status(status) do
    if status == "Yes" do
      true
    else
      false
    end
  end
end
