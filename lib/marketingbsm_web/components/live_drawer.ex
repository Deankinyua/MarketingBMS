defmodule MarketingbsmWeb.LiveDrawer do
  @moduledoc """
  Renders a navigation drawer as a child liveview
  """
  use MarketingbsmWeb, :live_view
  alias MarketingbsmWeb.NavigationComponent

  alias Marketingbsm.Accounts

  @impl true
  def mount(_params, session, socket) do
    %{"active_tab" => active_tab, "hiderr" => hiderr, "user" => "user?id=" <> user_id} = session
    current_user = Accounts.get_user_by_id!(user_id)

    socket =
      socket
      |> assign(:current_user, current_user)

    Phoenix.PubSub.subscribe(Marketingbsm.PubSub, "#{socket.assigns.current_user.id}")

    {:ok,
     socket
     |> assign(:hiderr, hiderr)
     |> assign(:active_tab, active_tab), layout: false}
  end

  @impl true
  @spec handle_event(<<_::40, _::_*88>>, map(), any()) :: {:noreply, any()}
  def handle_event("on_live_navigate", %{"active_tab" => active_tab} = _params, socket) do
    {:noreply, socket |> assign(:active_tab, active_tab)}
  end

  def handle_info({:close_modal}, socket) do
    hiderr = socket.assigns.hiderr
    new_hiderr = NavHelper.toggle_nav(hiderr)

    {:noreply,
     socket
     |> assign(hiderr: new_hiderr)}
  end

  @impl true
  def handle_info(%{event: "notification", title: title, message: message, type: type}, socket) do
    {:noreply,
     push_event(socket, "notify", %{
       title: title,
       message: message,
       type: type
     })}
  end

  @impl true
  def handle_info(%{event: "on_live_navigate", active_tab: active_tab} = _params, socket) do
    {:noreply, socket |> assign(:active_tab, active_tab)}
  end

  @impl true
  def handle_info(
        %{
          event: "update_profile"
        },
        socket
      ) do
    current_user =
      Marketingbsm.Accounts.User
      |> Ash.get(socket.assigns.current_user.id)

    {:noreply, socket |> assign(:current_user, current_user)}
  end

  @impl true
  def handle_info(
        %{event: "update", payload: %{data: %Marketingbsm.Accounts.User{} = _user}},
        socket
      ) do
    current_user =
      Marketingbsm.Accounts.User
      |> Ash.get(socket.assigns.current_user.id)

    {:noreply, socket |> assign(:current_user, current_user)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <NavigationComponent.drawer active_tab={@active_tab} user={@current_user} hiderr={@hiderr} />
    """
  end
end
