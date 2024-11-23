defmodule MarketingbsmWeb.ReportLive.Index do
  use MarketingbsmWeb, :live_view

  alias Tremorx.Theme

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        <%= live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{
            "active_tab" => "report",
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
                <Text.bold>Reports</Text.bold>
              </Text.title>

              <Text.subtitle color="gray">
                Use this for your check-ins, check-outs and Reports.
              </Text.subtitle>
            </Layout.flex>
          </Layout.flex>

          <Layout.flex flex_direction="col" justify_content="center" class="my-10">
            <Layout.flex
              flex_direction="col"
              align_items="center"
              class="grow mb-4 border-gray-300 border-2 border-dotted py-8 my-10 max-w-2xl"
            >
              <Text.title class="text-xl my-4">
                <Text.bold>Check-In</Text.bold>
              </Text.title>

              <Text.subtitle color="gray" class="mb-6">
                Upload Photo first then your details.
              </Text.subtitle>

              <Button.button size="xl" phx-click={JS.patch(~p"/checkins/new")}>
                <:icon>
                  <.icon name="hero-plus" />
                </:icon>
                Check-In
              </Button.button>
            </Layout.flex>

            <Layout.flex
              flex_direction="col"
              align_items="center"
              class="grow mb-4 border-gray-300 border-2 py-8 border-dotted my-10 max-w-2xl"
            >
              <Text.title class="text-xl my-4">
                <Text.bold>Check-Out</Text.bold>
              </Text.title>

              <Text.subtitle color="gray" class="mb-6">
                Upload Photo first then your details.
              </Text.subtitle>

              <Button.button size="xl" phx-click={JS.patch(~p"/checkouts/new")}>
                <:icon>
                  <.icon name="hero-plus" />
                </:icon>
                Check-Out
              </Button.button>
            </Layout.flex>

            <Layout.flex
              flex_direction="col"
              align_items="center"
              class="grow mb-4 border-gray-300 border-2 py-8 border-dotted my-10 max-w-2xl"
            >
              <Text.title class="text-xl my-4">
                <Text.bold>Closing Report</Text.bold>
              </Text.title>

              <Text.subtitle color="gray" class="mb-6">
                Use this to upload your closing report and enter the the details in chronological order.
              </Text.subtitle>

              <Button.button size="xl" phx-click={JS.patch(~p"/reports/new")}>
                <:icon>
                  <.icon name="hero-plus" />
                </:icon>
                Closing Report
              </Button.button>
            </Layout.flex>
          </Layout.flex>

          <.modal
            :if={@live_action in [:new, :edit]}
            id="reports-modal"
            show
            on_cancel={JS.patch(~p"/reports")}
          >
            <.live_component
              module={MarketingbsmWeb.ReportLive.FormComponent}
              id={(@report && @report.project_id) || :new}
              title={@page_title}
              current_user={@current_user.id}
              action={@live_action}
              report={@report}
              patch={~p"/reports"}
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

    {
      :ok,
      socket
      |> stream(
        :report,
        Ash.read!(Marketingbsm.Record.Report, actor: socket.assigns[:current_user])
      )
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"project_id" => project_id}) do
    socket
    |> assign(:page_title, "Edit report")
    |> assign(
      :report,
      Ash.get!(Marketingbsm.Record.Report, project_id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New report")
    |> assign(:report, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing report plural")
    |> assign(:report, nil)
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
