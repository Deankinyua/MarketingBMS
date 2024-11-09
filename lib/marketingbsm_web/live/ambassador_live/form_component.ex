defmodule MarketingbsmWeb.AmbassadorLive.FormComponent do
  use MarketingbsmWeb, :live_component

  alias Marketingbsm.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <Text.title class="text-xl">
          <Text.bold><%= @title %></Text.bold>
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

            <.input field={@form[:ambassador_email]} type="text" label="Email" />
          </Layout.col>

          <Button.button type="submit" size="xl" class="mt-2 w-min" phx-disable-with="Saving...">
            Register
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
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"ambassador" => ambassador_params} = params, socket) do
    dbg(params)

    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, ambassador_params))}
  end

  def handle_event("save", %{"ambassador" => ambassador_params}, socket) do
    %{"ambassador_email" => email} = ambassador_params

    case Accounts.get_user(email) do
      {:ok, user} ->
        ambassador_params = %{id: user.id}

        case AshPhoenix.Form.submit(socket.assigns.form, params: ambassador_params) do
          {:ok, ambassador} ->
            notify_parent({:saved, ambassador})

            socket =
              socket
              |> put_flash(:info, "You are now an Ambassador")
              |> push_patch(to: socket.assigns.patch)

            {:noreply, socket}

          {:error, _form} ->
            {:noreply,
             socket
             |> put_flash(:error, "You are already an Ambassador")
             |> push_patch(to: socket.assigns.patch)}
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

  defp assign_form(%{assigns: %{ambassador: ambassador}} = socket) do
    form =
      if ambassador do
        AshPhoenix.Form.for_update(ambassador, :update,
          as: "ambassador",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Marketingbsm.Activation.Ambassador, :create,
          as: "ambassador",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
