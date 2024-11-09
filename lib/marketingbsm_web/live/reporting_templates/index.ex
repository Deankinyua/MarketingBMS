defmodule MarketingbsmWeb.TemplateLive.Index do
  use MarketingbsmWeb, :live_view

  alias Marketingbsm.ProjectGeneral

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        <%= live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{"active_tab" => "template", "user" => "user?id=#{@current_user.id}"},
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
                <Text.bold>Reporting Templates</Text.bold>
              </Text.title>

              <Text.subtitle color="gray">
                Templates define how the Brand Ambassadors are going to Report Sales
              </Text.subtitle>
            </Layout.flex>

            <Button.button size="xl" phx-click={JS.patch(~p"/templates/new")}>
              <:icon>
                <.icon name="hero-plus" />
              </:icon>
              Create Template
            </Button.button>
          </Layout.flex>

          <.table id="templates" rows={@streams.templates}>
            <:col :let={{_id, template}} label="Project Name">
              <%= ProjectGeneral.get_project_by_id!(template.project_id).name %>
            </:col>
            <:col :let={{_id, template}} label="Field 1"><%= template.field_1 %></:col>
            <:col :let={{_id, template}} label="Field 2"><%= template.field_2 %></:col>
            <:col :let={{_id, template}} label="Field 3"><%= template.field_3 %></:col>
            <:col :let={{_id, template}} label="Field 4"><%= template.field_4 %></:col>
            <:col :let={{_id, template}} label="Field 5"><%= template.field_5 %></:col>
            <:col :let={{_id, template}} label="Field 6"><%= template.field_6 %></:col>
            <:col :let={{_id, template}} label="Field 7"><%= template.field_7 %></:col>
            <:col :let={{_id, template}} label="Field 8"><%= template.field_8 %></:col>
            <:col :let={{_id, template}} label="Field 9"><%= template.field_9 %></:col>
            <:col :let={{_id, template}} label="Field 10"><%= template.field_10 %></:col>
            <:col :let={{_id, template}} label="Field 11"><%= template.field_11 %></:col>
            <:col :let={{_id, template}} label="Field 12"><%= template.field_12 %></:col>
            <:col :let={{_id, template}} label="Field 13"><%= template.field_13 %></:col>
            <:col :let={{_id, template}} label="Field 14"><%= template.field_14 %></:col>
            <:col :let={{_id, template}} label="Field 15"><%= template.field_15 %></:col>
            <:col :let={{_id, template}} label="Field 16"><%= template.field_16 %></:col>
            <:col :let={{_id, template}} label="Field 17"><%= template.field_17 %></:col>
            <:col :let={{_id, template}} label="Field 18"><%= template.field_18 %></:col>
            <:col :let={{_id, template}} label="Field 19"><%= template.field_19 %></:col>
            <:col :let={{_id, template}} label="Field 20"><%= template.field_20 %></:col>
          </.table>

          <.modal
            :if={@live_action in [:new, :edit]}
            id="label-modal"
            show
            on_cancel={JS.patch(~p"/templates")}
          >
            <.live_component
              module={MarketingbsmWeb.TemplateLive.FormComponent}
              id={(@template && @template.project_id) || :new}
              title={@page_title}
              current_user={@current_user}
              action={@live_action}
              template={@template}
              patch={~p"/templates"}
            />
          </.modal>
        </Layout.flex>
      </Layout.flex>
    </div>
    """
  end

  @impl true

  def mount(_params, _session, socket) do
    {:ok, stream(socket, :templates, ProjectGeneral.list_templates!())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"project_id" => project_id}) do
    socket
    |> assign(:page_title, "Edit Label")
    |> assign(
      :template,
      Ash.get!(Marketingbsm.ProjectGeneral.Template, project_id,
        actor: socket.assigns.current_user
      )
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Reporting Template")
    |> assign(:template, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Reporting Templates")
    |> assign(:template, nil)
  end

  # @impl true
  # def handle_info({MarketingbsmWeb.templateLive.FormComponent, {:saved, template}}, socket) do
  #   {:noreply, stream_insert(socket, :templates, template)}
  # end
end
