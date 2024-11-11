defmodule MarketingbsmWeb.ReportLive.Index do
  use MarketingbsmWeb, :live_view

  import MarketingbsmWeb.TemplateLive.FormComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        <%= live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{"active_tab" => "report", "user" => "user?id=#{@current_user.id}"},
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
                <Text.bold>Reports</Text.bold>
              </Text.title>

              <Text.subtitle color="gray">
                Use this to for your check-ins, check-outs and Reports.
              </Text.subtitle>
            </Layout.flex>

            <Button.button size="xl" phx-click={JS.patch(~p"/reports/new")}>
              <:icon>
                <.icon name="hero-plus" />
              </:icon>
              Report
            </Button.button>
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
              current_user={@current_user}
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
    {:ok,
     socket
     |> stream(
       :report,
       Ash.read!(Marketingbsm.Record.Report, actor: socket.assigns[:current_user])
     )
     |> fetch_projects()
     |> assign_new(:current_user, fn -> nil end)}
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
end
