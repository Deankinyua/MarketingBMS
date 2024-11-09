defmodule MarketingbsmWeb.AmbassadorLive.Show do
  use MarketingbsmWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Ambassador <%= @ambassador.id %>
      <:subtitle>This is a ambassador record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/ambassadors/#{@ambassador}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit ambassador</.button>
        </.link>
      </:actions>
    </.header>

    <.back navigate={~p"/ambassadors"}>Back to ambassadors</.back>

    <.modal
      :if={@live_action == :edit}
      id="ambassador-modal"
      show
      on_cancel={JS.patch(~p"/ambassadors/#{@ambassador}")}
    >
      <.live_component
        module={MarketingbsmWeb.AmbassadorLive.FormComponent}
        id={@ambassador.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        ambassador={@ambassador}
        patch={~p"/ambassadors/#{@ambassador}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :ambassador,
       Ash.get!(Marketingbsm.Activation.Ambassador, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Ambassador"
  defp page_title(:edit), do: "Edit Ambassador"
end
