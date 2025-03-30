defmodule MarketingbsmWeb.ManagementLive.FormComponent do
  use MarketingbsmWeb, :live_component

  alias Marketingbsm.Accounts
  alias Marketingbsm.Management

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <Text.title class="text-xl">
          <Text.bold>{@title}</Text.bold>
        </Text.title>

        <Text.subtitle color="gray">
          Enter the Email you registered with.
        </Text.subtitle>

        <Layout.divider class="my-4" />

        <.form :let={f} for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
          <Layout.col class="space-y-1.5">
            <label for="email">
              <Text.text class="text-tremor-content">
                Email
              </Text.text>
            </label>

            <Input.text_input
              name={f[:manager_email].name}
              placeholder="Email..."
              type="text"
              field={f[:manager_email]}
              value={f[:manager_email].value}
            />

            <.input field={@form[:role]} type="select" options={@role_selector} label="Choose Role" />
          </Layout.col>

          <Button.button type="submit" size="xl" class="mt-2 w-min" phx-disable-with="Creating...">
            Create
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
     |> role_selector()
     |> assign_form()}
  end

  defp role_selector(socket) do
    socket |> assign(role_selector: ["Project Leader", "Team Leader"])
  end

  @impl true
  def handle_event("validate", %{"manager" => manager_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, manager_params))}
  end

  def handle_event("save", %{"manager" => manager_params}, socket) do
    %{"manager_email" => email} = manager_params

    role = manager_params["role"]

    case Accounts.get_user(email) do
      {:ok, user} ->
        case return_role(role) do
          :manager ->
            manager_params = %{id: user.id}

            case AshPhoenix.Form.submit(socket.assigns.form, params: manager_params) do
              {:ok, manager} ->
                notify_parent({:saved_manager, manager})

                socket =
                  socket
                  |> put_flash(:info, "Selected Individul has been given the Project Leader Role")
                  |> push_patch(to: socket.assigns.patch)

                {:noreply, socket}

              {:error, _form} ->
                {:noreply,
                 socket
                 |> put_flash(
                   :error,
                   "You are not authorized to complete this action or role already exists"
                 )
                 |> push_patch(to: socket.assigns.patch)}
            end

          :leader ->
            leader_params = %{id: user.id}

            case Management.create_leader(leader_params, actor: socket.assigns.current_user) do
              {:ok, leader} ->
                notify_parent({:saved_leader, leader})

                socket =
                  socket
                  |> put_flash(:info, "Team Leader Role has been assigned to the individual")
                  |> push_patch(to: socket.assigns.patch)

                {:noreply, socket}

              {:error, _form} ->
                {:noreply,
                 socket
                 |> put_flash(
                   :error,
                   "You are Not authorized to perform this action or role already exists"
                 )
                 |> push_patch(to: socket.assigns.patch)}
            end
        end

      _ ->
        socket =
          socket
          |> put_flash(:error, "Email is Invalid")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{manager: manager}} = socket) do
    form =
      if manager do
        AshPhoenix.Form.for_update(manager, :update,
          as: "manager",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Marketingbsm.Management.ProjectManager, :create,
          as: "manager",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def return_role(role) do
    if role == "Team Leader" do
      :leader
    else
      :manager
    end
  end
end
