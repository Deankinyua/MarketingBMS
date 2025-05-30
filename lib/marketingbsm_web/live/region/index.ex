defmodule MarketingbsmWeb.RegionLive.Index do
  use MarketingbsmWeb, :live_view

  alias Tremorx.Components.Text
  alias Tremorx.Components.Table
  alias Tremorx.Components.Button
  alias Tremorx.Theme
  alias Marketingbsm.Management

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        <%= live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{
            "active_tab" => "organization",
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
                <Text.bold>Regions</Text.bold>
              </Text.title>

              <Text.subtitle color="gray">
                Regions hold Outlets.
              </Text.subtitle>

              <Text.subtitle color="gray" class="mb-10">
                <Text.bold>DELETING</Text.bold>
                a region will delete
                <Text.bold>ALL</Text.bold>
                of the
                <Text.bold>OUTLETS</Text.bold>
                in that region!!
              </Text.subtitle>
            </Layout.flex>

            <Button.button size="xl" phx-click={JS.patch(~p"/regions/new")}>
              <:icon>
                <.icon name="hero-plus" />
              </:icon>
              New Region
            </Button.button>
          </Layout.flex>

          <Table.table class="w-full">
            <Table.table_head class="rounded-t-md border-b-[1px]">
              <Table.table_row class="hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted">
                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Name
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
              id="table_stream_regions"
              phx-update="stream"
              class="divide-y overflow-y-auto"
            >
              <Table.table_row
                :for={{dom_id, region} <- @streams.regions}
                id={"#{dom_id}"}
                class="group hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted"
              >
                <.live_component
                  module={MarketingbsmWeb.RegionLive.RowComponent}
                  id={dom_id}
                  region={region}
                  dom_id={dom_id}
                >
                  <Table.table_cell>
                    <%= region.name %>
                  </Table.table_cell>
                </.live_component>
              </Table.table_row>
            </Table.table_body>
          </Table.table>

          <.modal
            :if={@live_action in [:new, :edit]}
            id="region-modal"
            show
            on_cancel={JS.patch(~p"/regions")}
          >
            <.live_component
              module={MarketingbsmWeb.RegionLive.FormComponent}
              id={(@region && @region.id) || :new}
              title={@page_title}
              action={@live_action}
              region={@region}
              patch={~p"/regions"}
              current_user={@current_user}
            />
          </.modal>
        </Layout.flex>
      </Layout.flex>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket = socket |> assign(:hiderr, "")

    id = socket.assigns.current_user.id

    case Management.get_manager(id) do
      {:ok, _result} ->
        {:ok, stream(socket, :regions, Ash.read!(Marketingbsm.Outlet.Region))}

      {:error, _error} ->
        {:ok, stream(socket, :regions, [])}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Region")
    |> assign(:region, Ash.get!(Marketingbsm.Outlet.Region, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Region")
    |> assign(:region, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Regions")
    |> assign(:region, nil)
  end

  @impl true
  def handle_info({MarketingbsmWeb.RegionLive.FormComponent, {:saved, region}}, socket) do
    {:noreply, stream_insert(socket, :regions, region)}
  end

  @impl true
  def handle_event("delete", %{"region_id" => id} = _params, socket) do
    region = Ash.get!(Marketingbsm.Outlet.Region, id)
    Ash.destroy!(region, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :regions, region)}
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
