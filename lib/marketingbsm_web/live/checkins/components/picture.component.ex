defmodule MarketingbsmWeb.PictureLive.Component do
  use MarketingbsmWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div phx="showPicture">
      <div><img src={@checkin} height="150" /></div>
      <div>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end
end
