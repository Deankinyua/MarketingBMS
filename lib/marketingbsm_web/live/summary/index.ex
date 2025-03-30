defmodule MarketingbsmWeb.SummaryLive.Index do
  use MarketingbsmWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        {live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{
            "active_tab" => "checkin",
            "hiderr" => @hiderr,
            "user" => "user?id=#{@current_user.id}"
          },
          id: "live_drawer",
          sticky: true
        )}
        <Layout.flex
          flex_direction="col"
          align_items="start"
          justify_content="start"
          class="flex-1 px-8 py-8 h-full overflow-y-auto bg-gray-50/75"
        >
        </Layout.flex>
      </Layout.flex>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:hiderr, "")

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Check In")
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing checkins")
  end

  defp apply_action(socket, :see, _params) do
    socket
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

  # @impl true
  # def handle_event("close", _params, socket) do
  #   Phoenix.PubSub.broadcast(
  #     Marketingbsm.PubSub,
  #     "#{socket.assigns.current_user.id}",
  #     {:toggle_drawer}
  #   )

  #   {:noreply, socket}
  # end
end
