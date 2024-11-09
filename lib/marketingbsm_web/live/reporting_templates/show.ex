defmodule MarketingbsmWeb.TemplateLive.Show do
  use MarketingbsmWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Label <%= @template.id %>
      <:subtitle>This is a template record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/templates/#{@template}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit template</.button>
        </.link>
      </:actions>
    </.header>

    <.back navigate={~p"/templates"}>Back to templates</.back>

    <.modal
      :if={@live_action == :edit}
      id="template-modal"
      show
      on_cancel={JS.patch(~p"/templates/#{@template}")}
    >
      <.live_component
        module={MarketingbsmWeb.TemplateLive.FormComponent}
        id={@template.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        template={@template}
        patch={~p"/templates/#{@template}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"project_id" => project_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :template,
       Ash.get!(Marketingbsm.ProjectGeneral.Template, project_id,
         actor: socket.assigns.current_user
       )
     )}
  end

  defp page_title(:show), do: "Show template"
  defp page_title(:edit), do: "Edit template"
end
