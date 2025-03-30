defmodule MarketingbsmWeb.CheckinLive.Show do
  use MarketingbsmWeb, :live_view

  require Ash.Query

  alias Marketingbsm.ProjectGeneral
  alias Marketingbsm.Outlet

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
          <Layout.flex justify_content="between">
            <Layout.flex flex_direction="col" align_items="start" class="grow">
              <Text.title class="text-xl">
                <Text.bold>{@project.name} Project Check-Ins</Text.bold>
              </Text.title>

              <Text.subtitle color="gray" class="mb-2">
                <strong>{@count}</strong> Brand Ambassadors have checked In
              </Text.subtitle>

              <Text.subtitle color="gray" class="mb-10">
                <strong>Scroll</strong> to Load More Ambassadors as they are checking in.
              </Text.subtitle>
            </Layout.flex>
          </Layout.flex>

          <div class="sm:hidden">
            <Layout.grid num_items="1">
              <section :for={{dom_id, checkin} <- @streams.checkins} id={"photos_small#{dom_id}"}>
                <div class="mr-4 mb-4">
                  <.live_component
                    module={MarketingbsmWeb.PictureLive.Component}
                    id={"small#{dom_id}"}
                    checkin={call(checkin.file.original_filename)}
                    dom_id={dom_id}
                  >
                    <Text.text class="font-semibold text-center">
                      {Outlet.get_outlet!(checkin.outlet_id).name}
                    </Text.text>
                  </.live_component>
                </div>
              </section>
            </Layout.grid>
          </div>

          <div class="hidden sm:block md:hidden">
            <Layout.grid num_items="2">
              <section :for={{dom_id, checkin} <- @streams.checkins} id={"photos_medium#{dom_id}"}>
                <div class="mr-4 mb-4">
                  <.live_component
                    module={MarketingbsmWeb.PictureLive.Component}
                    id={"medium#{dom_id}"}
                    checkin={call(checkin.file.original_filename)}
                    dom_id={dom_id}
                  >
                    <Text.text class="font-semibold text-center">
                      {Outlet.get_outlet!(checkin.outlet_id).name}
                    </Text.text>
                  </.live_component>
                </div>
              </section>
            </Layout.grid>
          </div>

          <div class="hidden md:block">
            <Layout.grid num_items="5">
              <section :for={{dom_id, checkin} <- @streams.checkins} id={"photos_large#{dom_id}"}>
                <div class="mr-4 mb-4">
                  <.live_component
                    module={MarketingbsmWeb.PictureLive.Component}
                    id={"large#{dom_id}"}
                    checkin={call(checkin.file.original_filename)}
                    dom_id={dom_id}
                  >
                    <Text.text class="font-semibold text-center">
                      {Outlet.get_outlet!(checkin.outlet_id).name}
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

          <div id="infinite-scroll-marker" phx-hook="InfiniteScroll" data-page={@page}></div>
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
      |> assign(:page, 1)

    {:ok, socket}
  end

  def call(filename) do
    "http://127.0.0.1:9000/marketingbsm/checkinphoto/#{filename}"
  end

  def call_outlet(outlet) do
    "#{outlet}"
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    date =
      Date.utc_today()

    checkins = fetch_checkins(date, id)

    count = fetch_ambassador_count(date, id)

    {:noreply,
     socket
     |> stream(
       :checkins,
       checkins
     )
     |> assign(:count, count)
     |> assign(:project_id, id)
     |> assign(
       :project,
       Ash.get!(ProjectGeneral.Project, id, actor: socket.assigns.current_user)
     )}
  end

  @impl true
  def handle_event("delete", %{"checkin_id" => id}, socket) do
    checkin = Ash.get!(Marketingbsm.Clockin.Checkin, id, actor: socket.assigns.current_user)
    Ash.destroy!(checkin, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :checkins, checkin)}
  end

  @impl true
  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, assign(socket, page: assigns.page + 1) |> get_checkins()}
  end

  defp get_checkins(%{assigns: %{page: page}} = socket) do
    id = socket.assigns.project_id

    date =
      Date.utc_today()

    checkins = fetch_checkins(date, id)
    count = fetch_ambassador_count(date, id)

    socket = stream(socket, :checkins, checkins)

    socket
    |> assign(page: page)
    |> assign(count: count)
  end

  defp fetch_checkins(date, id) do
    query_results =
      Marketingbsm.Clockin.Checkin
      |> Ash.Query.filter(project_id: id)
      |> Ash.Query.filter(create_date: date)
      |> Ash.read!(page: [limit: 50])

    checkins = Map.get(query_results, :results)
    checkins
  end

  defp fetch_ambassador_count(date, id) do
    ambassador_count =
      Marketingbsm.Clockin.Checkin
      |> Ash.Query.filter(project_id: id)
      |> Ash.Query.filter(create_date: date)
      |> Ash.read!(page: [limit: 150])

    ambassadors = Map.get(ambassador_count, :results)

    count = Enum.count(ambassadors)
    count
  end
end
