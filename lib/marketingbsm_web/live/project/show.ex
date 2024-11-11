defmodule MarketingbsmWeb.ProjectLive.Show do
  use MarketingbsmWeb, :live_view

  require Ash.Query

  alias Marketingbsm.ProjectGeneral
  alias Marketingbsm.Accounts
  alias Marketingbsm.Outlet

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        <%= live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{"active_tab" => "project", "user" => "user?id=#{@current_user.id}"},
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
                <Text.bold><%= @project.name %> Project</Text.bold>
              </Text.title>

              <Text.subtitle color="gray" class="mb-10">
                These are reports for
                <Text.bold><%= @project.name %></Text.bold>
                .
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
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis text-center">
                    Outlet Name
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_1 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_2 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_3 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_4 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_5 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_6 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_7 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_8 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_9 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_10 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_11 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_12 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_13 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_14 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_15 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_16 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_17 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_18 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_19 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    <%= @result.field_20 %>
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Total Sales
                  </Text.text>
                </Table.table_cell>
              </Table.table_row>
            </Table.table_head>

            <Table.table_body
              id="table_stream_projects"
              phx-update="stream"
              class="divide-y overflow-y-auto"
            >
              <Table.table_row
                :for={{dom_id, record} <- @streams.records}
                id={"#{dom_id}"}
                class="group hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted"
              >
                <Table.table_cell>
                  <%= Accounts.get_user_by_id!(record.ambassador_id).name %>
                </Table.table_cell>
                <Table.table_cell>
                  <%= Outlet.get_outlet!(record.outlet_id).name %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_1 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_2 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_3 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_4 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_5 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_6 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_7 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_8 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_9 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_10 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_11 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_12 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_13 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_14 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_15 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_16 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_17 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_18 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_19 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.field_20 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= record.total_sales %>
                </Table.table_cell>
              </Table.table_row>
            </Table.table_body>
          </Table.table>

          <Button.button size="xl" class="mt-2 w-min">
            <.link navigate={~p"/projects"}>
              Back to Projects
            </.link>
          </Button.button>
        </Layout.flex>
      </Layout.flex>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    dbg(socket.assigns)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    result = ProjectGeneral.get_template_by_project_id!(id)

    query_results =
      Marketingbsm.Record.Report
      |> Ash.Query.filter(project_id: id)
      |> Ash.Query.sort(total_sales: :desc)
      |> Ash.read!(page: [limit: 50])

    reports = Map.get(query_results, :results)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :result,
       result
     )
     |> stream(
       :records,
       reports
     )
     |> assign(
       :project,
       Ash.get!(ProjectGeneral.Project, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Project"
  defp page_title(:edit), do: "Edit Project"
end
