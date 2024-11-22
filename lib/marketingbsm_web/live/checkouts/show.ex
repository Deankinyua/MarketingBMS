defmodule MarketingbsmWeb.CheckoutLive.Show do
  use MarketingbsmWeb, :live_view

  require Ash.Query

  alias Marketingbsm.ProjectGeneral
  alias Marketingbsm.Outlet

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

        <Layout.flex
          flex_direction="col"
          align_items="start"
          justify_content="start"
          class="flex-1 px-8 py-8 h-full overflow-y-auto bg-gray-50/75"
        >
          <Layout.flex justify_content="between">
            <Layout.flex flex_direction="col" align_items="start" class="grow">
              <Text.title class="text-xl">
                <Text.bold><%= @project.name %> Project Check-Ins</Text.bold>
              </Text.title>

              <Text.subtitle color="gray" class="mb-10">
                <strong><%= @count %></strong> Brand Ambassadors have checked out
              </Text.subtitle>
            </Layout.flex>
          </Layout.flex>

          <div class="hidden sm:block md:hidden">
            <Layout.grid num_items="2">
              <section :for={{dom_id, checkout} <- @streams.checkouts} id={"photos#{dom_id}"}>
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
              <section :for={{dom_id, checkout} <- @streams.checkouts} id={"photos#{dom_id}"}>
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

          <div class="sm:hidden">
            <Layout.grid num_items="1">
              <section :for={{dom_id, checkout} <- @streams.checkouts} id={"photos#{dom_id}"}>
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

          <Button.button size="xl" class="mt-2 w-min">
            <.link navigate={~p"/checkins"}>
              Back to Check-Ins
            </.link>
          </Button.button>
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

  def call(filename) do
    "http://127.0.0.1:9000/marketingbsm/photo/#{filename}"
  end

  def call_outlet(outlet) do
    "#{outlet}"
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    date =
      Date.utc_today()

    query_results =
      Marketingbsm.Clockin.Checkout
      |> Ash.Query.filter(project_id: id)
      |> Ash.Query.filter(create_date: date)
      # |> Ash.Query.sort(days_worked: :desc)
      |> Ash.read!(page: [limit: 50])

    checkouts = Map.get(query_results, :results)

    ambassador_count =
      Marketingbsm.Clockin.Checkout
      |> Ash.Query.filter(project_id: id)
      |> Ash.Query.filter(create_date: date)
      |> Ash.read!(page: [limit: 150])

    ambassadors = Map.get(ambassador_count, :results)

    count = Enum.count(ambassadors)

    {:noreply,
     socket
     |> stream(
       :checkouts,
       checkouts
     )
     |> assign(:count, count)
     |> assign(
       :project,
       Ash.get!(ProjectGeneral.Project, id, actor: socket.assigns.current_user)
     )}
  end

  @impl true
  def handle_event("delete", %{"checkin_id" => id}, socket) do
    checkout = Ash.get!(Marketingbsm.Clockin.Checkout, id, actor: socket.assigns.current_user)
    Ash.destroy!(checkout, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :checkouts, checkout)}
  end

  @impl true
  def handle_event("picture", %{"file_name" => file_name}, socket) do
    {:noreply, socket}
  end
end
