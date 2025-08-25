defmodule MarketingbsmWeb.CheckinLive.Index do
  use MarketingbsmWeb, :live_view
  alias Tremorx.Theme

  @impl Phoenix.LiveView
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
                <Text.bold>Listing Checkins</Text.bold>
              </Text.title>

              <Text.subtitle color="gray">
                Here you will be able to identify who has checked in
              </Text.subtitle>
              <Text.subtitle color="gray">
                and who has not and there respective times.
              </Text.subtitle>
            </Layout.flex>
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
                  module={MarketingbsmWeb.CheckinLive.RowComponentFilter}
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
            id="checkins-modal"
            show
            on_cancel={JS.patch(~p"/reports")}
          >
            <.live_component
              module={MarketingbsmWeb.CheckinLive.FormComponent}
              id={:new}
              title={@page_title}
              current_user={@current_user.id}
              action={@live_action}
              patch={~p"/checkins"}
            />
          </.modal>
        </Layout.flex>
      </Layout.flex>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:hiderr, "")

    {:ok,
     socket
     |> stream(
       :projects,
       Ash.read!(Marketingbsm.ProjectGeneral.Project, actor: socket.assigns[:current_user])
     )}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Check In")
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing checkins")
  end

  defp apply_action(socket, :see, _params) do
    socket
  end

  @impl Phoenix.LiveView
  def handle_info(%{event: "notification", title: title, message: message, type: type}, socket) do
    {:noreply,
     push_event(socket, "notify", %{
       title: title,
       message: message,
       type: type
     })}
  end

  @impl Phoenix.LiveView
  def handle_event("close", _params, socket) do
    Phoenix.PubSub.broadcast(
      Marketingbsm.PubSub,
      "#{socket.assigns.current_user.id}",
      {:toggle_drawer}
    )

    {:noreply, socket}
  end
end
