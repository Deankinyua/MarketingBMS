defmodule MarketingbsmWeb.CheckinLive.RowComponentFilter do
  use MarketingbsmWeb, :live_component
  alias Tremorx.Components.Button

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      {render_slot(@inner_block)}

      <Table.table_cell>
        <div class="flex justify-between px-6">
          <Button.button>
            <.link navigate={~p"/checkins/#{@project}"}>
              View Check-Ins
            </.link>
          </Button.button>

          <Button.button>
            <.link navigate={~p"/checkouts/#{@project}"}>
              View Check-Outs
            </.link>
          </Button.button>

          <Button.button>
            <.link navigate={~p"/summary/#{@project}"}>
              Summary
            </.link>
          </Button.button>
        </div>
      </Table.table_cell>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end
end
