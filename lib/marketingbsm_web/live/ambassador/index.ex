defmodule MarketingbsmWeb.AmbassadorLive.Index do
  use MarketingbsmWeb, :live_view

  alias Marketingbsm.Activation
  alias Marketingbsm.Accounts
  alias Tremorx.Theme

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        <%= live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{
            "active_tab" => "ambassador",
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
                <Text.bold>Brand Ambassadors</Text.bold>
              </Text.title>

              <Text.subtitle color="gray">
                There are <strong><%= @count %></strong> Brand Ambassadors.
              </Text.subtitle>
            </Layout.flex>

            <Button.button size="xl" phx-click={JS.patch(~p"/ambassadors/new")}>
              <:icon>
                <.icon name="hero-plus" />
              </:icon>
              Register as One
            </Button.button>
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
                    Availability
                  </Text.text>
                </Table.table_cell>
                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Location
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
                :for={{dom_id, ambassador} <- @streams.ambassadors}
                id={"#{dom_id}"}
                class="group hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted"
              >
                <Table.table_cell>
                  <%= Accounts.get_user_by_id!(ambassador.id).name %>
                </Table.table_cell>
                <Table.table_cell>
                  <%= ambassador.availability %>
                </Table.table_cell>
                <Table.table_cell>
                  <%= ambassador.location %>
                </Table.table_cell>
              </Table.table_row>
            </Table.table_body>
          </Table.table>

          <.modal
            :if={@live_action in [:new, :edit]}
            id="ambassador-modal"
            show
            on_cancel={JS.patch(~p"/ambassadors")}
          >
            <.live_component
              module={MarketingbsmWeb.AmbassadorLive.FormComponent}
              id={@ambassador || :new}
              title={@page_title}
              current_user={@current_user}
              action={@live_action}
              ambassador={@ambassador}
              patch={~p"/ambassadors"}
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
      |> assign(:hiderr, "")

    {:ok, stream(socket, :ambassadors, get_records())}
  end

  def get_count do
    Enum.count(get_records())
  end

  def get_records do
    ambassadors = Activation.list_ambassadors!()

    for ambassador <- ambassadors do
      ambassador
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ambassador")
    |> assign(
      :ambassador,
      Ash.get!(Marketingbsm.Activation.Ambassador, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ambassador")
    |> assign(:ambassador, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Ambassadors")
    |> assign(:ambassador, nil)
  end

  @impl true
  def handle_info({MarketingbsmWeb.AmbassadorLive.FormComponent, {:saved, ambassador}}, socket) do
    socket =
      socket
      |> assign(:count, socket.assigns.count + 1)

    {:noreply, stream_insert(socket, :ambassadors, ambassador)}
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
