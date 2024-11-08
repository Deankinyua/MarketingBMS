defmodule MarketingbsmWeb.ProjectLive.Index do
  use MarketingbsmWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full px-4 py-4">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        <%= live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{"active_tab" => "project", "user" => "user?id=#{@current_user.id}"},
          id: "live_drawer",
          sticky: true
        ) %>

        <.header>
          Listing Projects
          <:actions>
            <.link patch={~p"/projects/new"}>
              <.button>New Project</.button>
            </.link>
          </:actions>
        </.header>

        <.table
          id="projects"
          rows={@streams.projects}
          row_click={fn {_id, project} -> JS.navigate(~p"/projects/#{project}") end}
        >
          <:col :let={{_id, project}} label="Project Name"><%= project.name %></:col>
          <:col :let={{_id, project}} label="Freezed"><%= project.is_freezed %></:col>

          <:action :let={{_id, project}}>
            <div class="sr-only">
              <.link navigate={~p"/projects/#{project}"}>Show</.link>
            </div>

            <.link patch={~p"/projects/#{project}/edit"}>Edit</.link>
          </:action>

          <:action :let={{id, project}}>
            <.link
              phx-click={JS.push("delete", value: %{id: project.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          </:action>
        </.table>

        <.modal
          :if={@live_action in [:new, :edit]}
          id="project-modal"
          show
          on_cancel={JS.patch(~p"/projects")}
        >
          <.live_component
            module={MarketingbsmWeb.ProjectLive.FormComponent}
            id={(@project && @project.id) || :new}
            title={@page_title}
            current_user={@current_user}
            action={@live_action}
            project={@project}
            patch={~p"/projects"}
          />
        </.modal>
      </Layout.flex>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :projects,
       Ash.read!(Marketingbsm.ProjectGeneral.Project, actor: socket.assigns[:current_user])
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Project")
    |> assign(
      :project,
      Ash.get!(Marketingbsm.ProjectGeneral.Project, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Projects")
    |> assign(:project, nil)
  end

  @impl true
  def handle_info({MarketingbsmWeb.ProjectLive.FormComponent, {:saved, project}}, socket) do
    {:noreply, stream_insert(socket, :projects, project)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project =
      Ash.get!(Marketingbsm.ProjectGeneral.Project, id, actor: socket.assigns.current_user)

    Ash.destroy!(project, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :projects, project)}
  end
end
