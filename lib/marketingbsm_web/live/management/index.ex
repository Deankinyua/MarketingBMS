defmodule MarketingbsmWeb.ManagementLive.Index do
  use MarketingbsmWeb, :live_view

  alias Marketingbsm.Management
  alias Marketingbsm.Accounts
  alias Tremorx.Theme

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        <%= live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{
            "active_tab" => "management",
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
          <Layout.flex justify_content="between" class="">
            <Layout.flex flex_direction="col" align_items="start" class="grow">
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
              <Text.title class="text-xl">
                <Text.bold>Project Managers</Text.bold>
              </Text.title>

              <Text.subtitle color="gray"></Text.subtitle>
            </Layout.flex>

            <Button.button size="xl" phx-click={JS.patch(~p"/management/new")}>
              <:icon>
                <.icon name="hero-plus" />
              </:icon>
              Add a Manager
            </Button.button>
          </Layout.flex>

          <Table.table class="w-full">
            <Table.table_head class="rounded-t-md border-b-[1px]">
              <Table.table_row class="hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted">
                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Project Manager
                  </Text.text>
                </Table.table_cell>
              </Table.table_row>
            </Table.table_head>

            <Table.table_body
              id="table_stream_outlets"
              phx-update="stream"
              class="divide-y overflow-y-auto"
            >
              <Table.table_row
                :for={{dom_id, manager} <- @streams.managers}
                id={"#{dom_id}"}
                class="group hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted"
              >
                <.live_component
                  module={MarketingbsmWeb.ManagerLive.RowComponent}
                  id={dom_id}
                  manager={manager}
                  dom_id={dom_id}
                >
                  <Table.table_cell>
                    <%= Accounts.get_user_by_id!(manager.id).name %>
                  </Table.table_cell>
                </.live_component>
              </Table.table_row>
            </Table.table_body>
          </Table.table>

          <Table.table class="w-full">
            <Table.table_head class="rounded-t-md border-b-[1px]">
              <Table.table_row class="hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted">
                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Team Leader
                  </Text.text>
                </Table.table_cell>
              </Table.table_row>
            </Table.table_head>

            <Table.table_body
              id="table_stream_outlets"
              phx-update="stream"
              class="divide-y overflow-y-auto"
            >
              <Table.table_row
                :for={{dom_id, leader} <- @streams.leaders}
                id={"#{dom_id}"}
                class="group hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted"
              >
                <.live_component
                  module={MarketingbsmWeb.LeaderLive.RowComponent}
                  id={dom_id}
                  leader={leader}
                  dom_id={dom_id}
                >
                  <Table.table_cell>
                    <%= Accounts.get_user_by_id!(leader.id).name %>
                  </Table.table_cell>
                </.live_component>
              </Table.table_row>
            </Table.table_body>
          </Table.table>

          <.modal
            :if={@live_action in [:new, :edit]}
            id="manager-modal"
            show
            on_cancel={JS.patch(~p"/management")}
          >
            <.live_component
              module={MarketingbsmWeb.ManagementLive.FormComponent}
              id={@manager || :new}
              title={@page_title}
              current_user={@current_user}
              action={@live_action}
              manager={@manager}
              patch={~p"/management"}
            />
          </.modal>
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
      |> stream(:leaders, get_leaders())

    {:ok, stream(socket, :managers, get_managers())}
  end

  def get_managers do
    managers = Management.list_managers!()
    managers
  end

  def get_leaders do
    leaders = Management.list_leaders!()
    leaders
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Manager")
    |> assign(
      :manager,
      Ash.get!(Marketingbsm.Management.ProjectManager, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Manager")
    |> assign(:manager, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Managers")
    |> assign(:manager, nil)
  end

  @impl true
  def handle_info(
        {MarketingbsmWeb.ManagementLive.FormComponent, {:saved_manager, manager}},
        socket
      ) do
    {:noreply, stream_insert(socket, :managers, manager)}
  end

  @impl true
  def handle_info({MarketingbsmWeb.ManagementLive.FormComponent, {:saved_leader, leader}}, socket) do
    {:noreply, stream_insert(socket, :leaders, leader)}
  end

  @impl true
  def handle_event("delete_manager", %{"manager_id" => id}, socket) do
    manager = Ash.get!(Marketingbsm.Management.ProjectManager, id)

    case Management.destroy_manager(manager, actor: socket.assigns.current_user) do
      :ok ->
        {:noreply, stream_delete(socket, :managers, manager)}

      {:error, _error} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "You are Not authorized to perform this action"
         )}
    end
  end

  @impl true
  def handle_event("delete_leader", %{"leader_id" => id}, socket) do
    leader = Ash.get!(Marketingbsm.Management.TeamLeader, id)

    case Management.destroy_leader(leader, actor: socket.assigns.current_user) do
      :ok ->
        {:noreply, stream_delete(socket, :leaders, leader)}

      {:error, _error} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "You are Not authorized to perform this action"
         )}
    end
  end

  @impl true
  def handle_event("close", _params, socket) do
    Phoenix.PubSub.broadcast(
      Marketingbsm.PubSub,
      "#{socket.assigns.current_user.id}",
      {:toggle_drawer}
    )

    {:noreply, socket}
  end
end
