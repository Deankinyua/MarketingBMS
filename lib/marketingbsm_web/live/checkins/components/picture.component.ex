defmodule MarketingbsmWeb.PictureLive.Component do
  use MarketingbsmWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Layout.flex
        flex_direction="col"
        align_items="start"
        justify_content="start"
        class="flex-1  h-full overflow-y-auto bg-gray-50/75 w-48"
      >
        <div><img src={@checkin} height="150" /></div>
        <div>
          <%= render_slot(@inner_block) %>
        </div>
      </Layout.flex>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end
end
