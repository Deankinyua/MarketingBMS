defmodule MarketingbsmWeb.CheckoutLive.Index do
  use MarketingbsmWeb, :live_view
  alias Tremorx.Theme

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        <%= live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{
            "active_tab" => "checkin",
            "hiderr" => @hiderr,
            "user" => "user?id=#{@current_user.id}"
          },
          id: "live_drawer",
          sticky: true
        ) %>
        <Layout.flex flex_direction="col" justify_content="center" class="my-10">
          <.modal
            :if={@live_action in [:new, :edit]}
            id="checkouts-modal"
            show
            on_cancel={JS.patch(~p"/reports")}
          >
            <.live_component
              module={MarketingbsmWeb.CheckoutLive.FormComponent}
              id={:new}
              title={@page_title}
              current_user={@current_user}
              action={@live_action}
              patch={~p"/reports"}
            />
          </.modal>

          <Layout.flex
            flex_direction="col"
            align_items="center"
            class="grow mb-4 border-gray-300 border-2 py-8 border-dotted my-10 max-w-2xl"
          >
            <div class="ml-4">
              <.link phx-click={JS.push("close")}>
                <.icon
                  class={
                    Tails.classes([
                      Theme.get_sizing_style("xl", "height"),
                      Theme.get_sizing_style("xl", "width")
                    ])
                  }
                  name="hero-bars-3-solid"
                />
              </.link>
            </div>
            <Text.title class="text-xl my-4">
              <Text.bold>Closing Report</Text.bold>
            </Text.title>

            <Text.subtitle color="gray" class="mb-6">
              Use this to upload your closing report and enter the the details in chronological order.
            </Text.subtitle>

            <Button.button size="xl" phx-click={JS.patch(~p"/reports/new")}>
              <:icon>
                <.icon name="hero-plus" />
              </:icon>
              Closing Report
            </Button.button>
          </Layout.flex>
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
    |> assign(:page_title, "Check Out")
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing checkouts")
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

  @impl true
  def handle_event("close", _params, socket) do
    Phoenix.PubSub.broadcast(Marketingbsm.PubSub, "close_drawer", {:close_modal})
    {:noreply, socket}
  end
end
