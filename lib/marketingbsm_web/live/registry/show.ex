defmodule MarketingbsmWeb.RegistryLive.Show do
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
          session: %{"active_tab" => "checkin", "user" => "user?id=#{@current_user.id}"},
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
                <Text.bold><%= @project.name %> Project Registry</Text.bold>
              </Text.title>

              <Text.subtitle color="gray" class="mb-10">
                There are <strong><%= @count %></strong>
                Brand Ambassadors activating
                <Text.bold><%= @project.name %></Text.bold>
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
                    Days Worked
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Can Activate?
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis text-center">
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
                :for={{dom_id, registry} <- @streams.registries}
                id={"#{dom_id}"}
                class="group hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted"
              >
                <.live_component
                  module={MarketingbsmWeb.RegistryLive.RowComponent}
                  id={dom_id}
                  registry={registry}
                  dom_id={dom_id}
                >
                  <Table.table_cell>
                    <%= Accounts.get_user_by_id!(registry.ambassador_id).name %>
                  </Table.table_cell>

                  <Table.table_cell>
                    <%= ProjectGeneral.get_project_by_id!(registry.project_id).name %>
                  </Table.table_cell>

                  <Table.table_cell>
                    <%= Outlet.get_outlet!(registry.outlet_id).name %>
                  </Table.table_cell>

                  <Table.table_cell>
                    <%= registry.days_worked %>
                  </Table.table_cell>

                  <Table.table_cell>
                    <%= if registry.should_activate== true do %>
                      Yes
                    <% else %>
                      No
                    <% end %>
                  </Table.table_cell>
                </.live_component>
              </Table.table_row>
            </Table.table_body>
          </Table.table>

          <Button.button size="xl" class="mt-2 w-min">
            <.link navigate={~p"/registries"}>
              Back to Registries
            </.link>
          </Button.button>
        </Layout.flex>
      </Layout.flex>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    query_results =
      Marketingbsm.Record.Registry
      |> Ash.Query.filter(project_id: id)
      |> Ash.Query.sort(days_worked: :desc)
      |> Ash.read!(page: [limit: 50])

    reports = Map.get(query_results, :results)

    ambassador_count =
      Marketingbsm.Record.Registry
      |> Ash.Query.filter(project_id: id)
      |> Ash.Query.filter(should_activate: true)
      |> Ash.read!(page: [limit: 20])

    ambassadors = Map.get(ambassador_count, :results)

    count = Enum.count(ambassadors)

    {:noreply,
     socket
     |> stream(
       :registries,
       reports
     )
     |> assign(:count, count)
     |> assign(
       :project,
       Ash.get!(ProjectGeneral.Project, id, actor: socket.assigns.current_user)
     )}
  end

  @impl true
  def handle_event("delete", %{"registry_id" => id}, socket) do
    registry = Ash.get!(Marketingbsm.Record.Registry, id, actor: socket.assigns.current_user)
    Ash.destroy!(registry, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :registries, registry)}
  end
end
