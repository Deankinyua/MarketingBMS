defmodule MarketingbsmWeb.ShopLive.Index do
  use MarketingbsmWeb, :live_view

  alias Tremorx.Components.Table
  alias Marketingbsm.Outlet

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        <%= live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{"active_tab" => "outlet", "user" => "user?id=#{@current_user.id}"},
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
              <Text.title class="text-xl">
                <Text.bold>Outlets</Text.bold>
              </Text.title>

              <Text.subtitle color="gray">
                Information related to the Outlets.
              </Text.subtitle>

              <Text.subtitle color="gray">
                There are <strong><%= @count %></strong> Outlets.
              </Text.subtitle>
            </Layout.flex>

            <Button.button size="xl" phx-click={JS.patch(~p"/outlets/new")}>
              <:icon>
                <.icon name="hero-plus" />
              </:icon>
              New Shop
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
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Region Name
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
              id="table_stream_outlets"
              phx-update="stream"
              class="divide-y overflow-y-auto"
            >
              <Table.table_row
                :for={{dom_id, outlet} <- @streams.outlets}
                id={"#{dom_id}"}
                class="group hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted"
              >
                <.live_component
                  module={MarketingbsmWeb.ShopLive.RowComponent}
                  id={dom_id}
                  outlet={outlet}
                  dom_id={dom_id}
                >
                  <Table.table_cell>
                    <%= outlet.name %>
                  </Table.table_cell>

                  <Table.table_cell>
                    <%= Outlet.get_region!(outlet.region_id).name %>
                  </Table.table_cell>
                </.live_component>
              </Table.table_row>
            </Table.table_body>
          </Table.table>

          <.modal
            :if={@live_action in [:new, :edit]}
            id="shop-modal"
            show
            on_cancel={JS.patch(~p"/outlets")}
          >
            <.live_component
              module={MarketingbsmWeb.ShopLive.FormComponent}
              id={(@shop && @shop.id) || :new}
              title={@page_title}
              current_user={@current_user}
              action={@live_action}
              shop={@shop}
              patch={~p"/outlets"}
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
      |> assign(:count, get_count())

    {:ok,
     socket
     |> stream(
       :outlets,
       Ash.read!(Marketingbsm.Outlet.Shop, actor: socket.assigns[:current_user])
     )}
  end

  def get_count do
    Enum.count(Ash.read!(Marketingbsm.Outlet.Shop))
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Shop")
    |> assign(:shop, Ash.get!(Marketingbsm.Outlet.Shop, id, actor: socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Shop")
    |> assign(:shop, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Outlets")
    |> assign(:shop, nil)
  end

  @impl true
  def handle_info({MarketingbsmWeb.ShopLive.FormComponent, {:saved, shop}}, socket) do
    dbg(shop)
    dbg(socket.assigns.streams.outlets)

    socket =
      socket
      |> assign(:count, socket.assigns.count + 1)

    {:noreply, stream_insert(socket, :outlets, shop)}
  end

  @impl true
  def handle_event("delete", %{"outlet_id" => id}, socket) do
    outlet = Ash.get!(Marketingbsm.Outlet.Shop, id)
    Ash.destroy!(outlet)

    {:noreply, stream_delete(socket, :outlets, outlet)}
  end
end
