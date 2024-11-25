defmodule MarketingbsmWeb.SummaryLive.Show do
  use MarketingbsmWeb, :live_view

  require Ash.Query

  alias Marketingbsm.ProjectGeneral
  alias Marketingbsm.Accounts
  alias Marketingbsm.Outlet
  alias Marketingbsm.Clockin

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
                <strong><%= @count %></strong> Brand Ambassadors have checked In
              </Text.subtitle>
            </Layout.flex>
          </Layout.flex>

          <Table.table class="w-full">
            <Table.table_head class="rounded-t-md border-b-[1px]">
              <Table.table_row class="hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted">
                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Ambassador Name
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Project Name
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Outlet Name
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Time In
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Time Out
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Actions
                  </Text.text>
                </Table.table_cell>
              </Table.table_row>
            </Table.table_head>

            <Table.table_body
              id="table_stream_registries"
              phx-update="stream"
              class="divide-y overflow-y-auto"
            >
              <Table.table_row
                :for={{dom_id, checkin} <- @streams.checkins}
                id={"#{dom_id}"}
                class="group hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted"
              >
                <.live_component
                  module={MarketingbsmWeb.CheckinLive.RowComponent}
                  id={dom_id}
                  checkin={checkin}
                  dom_id={dom_id}
                >
                  <Table.table_cell>
                    <%= Accounts.get_user_by_id!(checkin.ambassador_id).name %>
                  </Table.table_cell>

                  <Table.table_cell>
                    <%= ProjectGeneral.get_project_by_id!(checkin.project_id).name %>
                  </Table.table_cell>

                  <Table.table_cell>
                    <%= Outlet.get_outlet!(checkin.outlet_id).name %>
                  </Table.table_cell>

                  <Table.table_cell>
                    <%= Time.to_string(Time.add(checkin.create_time, 3, :hour)) %>
                  </Table.table_cell>

                  <Table.table_cell>
                    <%= get_checkout_time(checkin.ambassador_id, checkin.create_date) %>
                  </Table.table_cell>
                </.live_component>
              </Table.table_row>
            </Table.table_body>
          </Table.table>

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

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    date =
      Date.utc_today()

    query_results =
      Marketingbsm.Clockin.Checkin
      |> Ash.Query.filter(project_id: id)
      |> Ash.Query.filter(create_date: date)
      |> Ash.read!(page: [limit: 50])

    checkins = Map.get(query_results, :results)

    ambassador_count =
      Marketingbsm.Clockin.Checkin
      |> Ash.Query.filter(project_id: id)
      |> Ash.Query.filter(create_date: date)
      |> Ash.read!(page: [limit: 150])

    ambassadors = Map.get(ambassador_count, :results)

    count = Enum.count(ambassadors)

    {:noreply,
     socket
     |> stream(
       :checkins,
       checkins
     )
     |> assign(:count, count)
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

  def get_checkout_time(ambassador_id, date) do
    # date =
    #   Date.utc_today()
    case Clockin.get_user_by_id(ambassador_id, date) do
      {:ok, checkout} ->
        Time.add(checkout.create_time, 3, :hour)

      {:error, _error} ->
        ""
    end
  end

  # def hours_worked(ambassador_id) do
  #   case Clockin.get_user_by_id(ambassador_id) do
  #     {:ok, checkout} ->
  #       Time.add(checkout.create_time, 3, :hour)

  #     {:error, _error} ->
  #       ""
  #   end
  # end
end
