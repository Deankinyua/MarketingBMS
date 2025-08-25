defmodule MarketingbsmWeb.CheckoutLive.Show do
  use MarketingbsmWeb, :live_view

  require Ash.Query

  alias Marketingbsm.ProjectGeneral
  alias Marketingbsm.Outlet

  @impl Phoenix.LiveView
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

        <Layout.flex
          flex_direction="col"
          align_items="start"
          justify_content="start"
          class="flex-1 px-8 py-8 h-full overflow-y-auto bg-gray-50/75"
        >
          <Layout.flex justify_content="between">
            <Layout.flex flex_direction="col" align_items="start" class="grow">
              <Text.title class="text-xl">
                <Text.bold><%= @project.name %> Project Check-Outs</Text.bold>
              </Text.title>

              <Text.subtitle color="gray" class="mb-2">
                <strong><%= @count %></strong> Brand Ambassadors have checked out
              </Text.subtitle>
              <Text.subtitle color="gray" class="mb-10">
                <strong>Scroll</strong> to Load More Ambassadors as they are checking out.
              </Text.subtitle>
            </Layout.flex>
          </Layout.flex>

          <div class="sm:hidden">
            <Layout.grid num_items="1">
              <section :for={{dom_id, checkout} <- @streams.checkouts} id={"photos_small#{dom_id}"}>
                <div class="mr-4 mb-4">
                  <.live_component
                    module={MarketingbsmWeb.PictureLive.Component}
                    id={"small#{dom_id}"}
                    checkin={call(checkout.file.original_filename)}
                    dom_id={dom_id}
                  >
                    <Text.text class="font-semibold text-center">
                      <%= Outlet.get_outlet!(checkout.outlet_id).name %>
                    </Text.text>
                  </.live_component>
                </div>
              </section>
            </Layout.grid>
          </div>

          <div class="hidden sm:block md:hidden">
            <Layout.grid num_items="2">
              <section :for={{dom_id, checkout} <- @streams.checkouts} id={"photos_medium#{dom_id}"}>
                <div class="mr-4 mb-4">
                  <.live_component
                    module={MarketingbsmWeb.PictureLive.Component}
                    id={"medium#{dom_id}"}
                    checkin={call(checkout.file.original_filename)}
                    dom_id={dom_id}
                  >
                    <Text.text class="font-semibold text-center">
                      <%= Outlet.get_outlet!(checkout.outlet_id).name %>
                    </Text.text>
                  </.live_component>
                </div>
              </section>
            </Layout.grid>
          </div>

          <div class="hidden md:block">
            <Layout.grid num_items="5">
              <section :for={{dom_id, checkout} <- @streams.checkouts} id={"photos_large#{dom_id}"}>
                <div class="mr-4 mb-4">
                  <.live_component
                    module={MarketingbsmWeb.PictureLive.Component}
                    id={"large#{dom_id}"}
                    checkin={call(checkout.file.original_filename)}
                    dom_id={dom_id}
                  >
                    <Text.text class="font-semibold text-center">
                      <%= Outlet.get_outlet!(checkout.outlet_id).name %>
                    </Text.text>
                  </.live_component>
                </div>
              </section>
            </Layout.grid>
          </div>

          <Button.button size="xl" class="mt-2 mb-72 w-min">
            <.link navigate={~p"/checkins"}>
              Back to Check-Ins
            </.link>
          </Button.button>

          <div id="infinite-scroll-marker-out" phx-hook="InfiniteScrollCheckout" data-page={@page}>
          </div>
        </Layout.flex>
      </Layout.flex>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:hiderr, "")
      |> assign(:page, 1)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => project_id}, _, socket) do
    date =
      Date.utc_today()

    checkouts = fetch_checkouts(date, project_id)

    count = fetch_ambassador_count(date, project_id)

    {:noreply,
     socket
     |> stream(
       :checkouts,
       checkouts
     )
     |> assign(:count, count)
     |> assign(:project_id, project_id)
     |> assign(
       :project,
       Ash.get!(ProjectGeneral.Project, project_id, actor: socket.assigns.current_user)
     )}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"checkin_id" => id}, socket) do
    checkout = Ash.get!(Marketingbsm.Clockin.Checkout, id, actor: socket.assigns.current_user)
    Ash.destroy!(checkout, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :checkouts, checkout)}
  end

  @impl true
  def handle_event("load-more-checkouts", _, %{assigns: assigns} = socket) do
    {:noreply,
     socket
     |> assign(:page, assigns.page + 1)
     |> get_checkouts()}
  end

  defp get_checkouts(socket) do
    project_id = socket.assigns.project_id

    date =
      Date.utc_today()

    socket
    |> stream(:checkouts, fetch_checkouts(date, project_id))
    |> assign(count: fetch_ambassador_count(date, project_id))
  end

  defp fetch_checkouts(date, project_id) do
    Marketingbsm.Clockin.Checkout
    |> Ash.Query.filter(project_id: project_id)
    |> Ash.Query.filter(create_date: date)
    |> Ash.read!(page: [limit: 50])
    |> Map.get(:results)
  end

  def fetch_ambassador_count(date, project_id) do
    Marketingbsm.Clockin.Checkout
    |> Ash.Query.filter(project_id: project_id)
    |> Ash.Query.filter(create_date: date)
    |> Ash.read!(page: [limit: 120])
    |> Map.get(:results)
    |> Enum.count()
  end

  def call(filename) do
    "http://127.0.0.1:9000/marketingbsm/checkoutphoto/#{filename}"
  end
end
