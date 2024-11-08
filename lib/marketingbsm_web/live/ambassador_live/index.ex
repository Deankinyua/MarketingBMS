defmodule MarketingbsmWeb.AmbassadorLive.Index do
  use MarketingbsmWeb, :live_view

  alias Marketingbsm.Activation
  alias Marketingbsm.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full px-4 py-4">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        <%= live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{"active_tab" => "ambassador", "user" => "user?id=#{@current_user.id}"},
          id: "live_drawer",
          sticky: true
        ) %>

        <.header>
          Listing Ambassadors
          <:actions>
            <.link patch={~p"/ambassadors/new"}>
              <.button>New Ambassador</.button>
            </.link>
          </:actions>
        </.header>

        <.table id="ambassadors" rows={@streams.ambassadors}>
          <:col :let={{_id, ambassador}} label="Name"><%= ambassador.name %></:col>
        </.table>

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
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :ambassadors, get_records())}
  end

  def get_records do
    ambassadors = Activation.list_ambassadors!()

    for ambassador <- ambassadors do
      Accounts.get_user_by_id!(ambassador.ambassador_id)
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"ambassador_id" => ambassador_id}) do
    socket
    |> assign(:page_title, "Edit Ambassador")
    |> assign(
      :ambassador,
      Ash.get!(Marketingbsm.Activation.Ambassador, ambassador_id,
        actor: socket.assigns.current_user
      )
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
end
