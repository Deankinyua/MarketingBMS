defmodule MarketingbsmWeb.RegistryLive.Index do
  use MarketingbsmWeb, :live_view
  alias Tremorx.Theme

  require Ash.Query
  alias Marketingbsm.Management

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        <%= live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{
            "active_tab" => "registry",
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
                <Text.bold>Registries</Text.bold>
              </Text.title>

              <Text.subtitle color="gray">
                Multiple Ambassadors can be assigned to the same outlet.
              </Text.subtitle>

              <Text.subtitle color="gray">
                Registries keep track of who should activate where.
              </Text.subtitle>

              <Text.subtitle color="gray">
                No Ambassador can activate 2 places at the same time.
              </Text.subtitle>
            </Layout.flex>

            <Button.button size="xl" phx-click={JS.patch(~p"/registries/new")}>
              <:icon>
                <.icon name="hero-plus" />
              </:icon>
              New Registry
            </Button.button>
          </Layout.flex>

          <Table.table class="w-full">
            <Table.table_head class="rounded-t-md border-b-[1px]">
              <Table.table_row class="hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted">
                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Project Name
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
              id="table_stream_projects"
              phx-update="stream"
              class="divide-y overflow-y-auto"
            >
              <Table.table_row
                :for={{dom_id, project} <- @streams.projects}
                id={"#{dom_id}"}
                class="group hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted"
              >
                <.live_component
                  module={MarketingbsmWeb.RegistryLive.RowComponentFilter}
                  id={dom_id}
                  project={project}
                  dom_id={dom_id}
                >
                  <Table.table_cell>
                    <%= project.name %>
                  </Table.table_cell>
                </.live_component>
              </Table.table_row>
            </Table.table_body>
          </Table.table>

          <.modal
            :if={@live_action in [:new, :edit]}
            id="registry-modal"
            show
            on_cancel={JS.patch(~p"/registries")}
          >
            <.live_component
              module={MarketingbsmWeb.RegistryLive.FormComponent}
              id={(@registry && @registry.id) || :new}
              title={@page_title}
              current_user={@current_user}
              action={@live_action}
              patch={~p"/registries"}
              registry={@registry}
            />
          </.modal>
        </Layout.flex>
      </Layout.flex>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :hiderr, "")

    id = socket.assigns.current_user.id

    case Management.get_manager(id) do
      {:ok, _result} ->
        {:ok,
         socket
         |> stream(
           :registries,
           Ash.read!(Marketingbsm.Record.Registry, actor: socket.assigns[:current_user])
         )
         |> stream(
           :projects,
           Ash.read!(Marketingbsm.ProjectGeneral.Project, actor: socket.assigns[:current_user])
         )}

      {:error, _error} ->
        case Management.get_leader(id) do
          {:ok, _result} ->
            {:ok,
             socket
             |> stream(
               :registries,
               Ash.read!(Marketingbsm.Record.Registry, actor: socket.assigns[:current_user])
             )
             |> stream(
               :projects,
               Ash.read!(Marketingbsm.ProjectGeneral.Project,
                 actor: socket.assigns[:current_user]
               )
             )}

          {:error, _error} ->
            socket = stream(socket, :projects, [])

            {:ok, stream(socket, :registries, [])}
        end
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Registry")
    |> assign(
      :registry,
      Ash.get!(Marketingbsm.Record.Registry, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Registry")
    |> assign(:registry, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing registries")
    |> assign(:registry, nil)
  end

  @impl true
  def handle_info({MarketingbsmWeb.RegistryLive.FormComponent, {:saved, registry}}, socket) do
    {:noreply, stream_insert(socket, :registries, registry)}
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
