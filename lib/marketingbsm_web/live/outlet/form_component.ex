defmodule MarketingbsmWeb.ShopLive.FormComponent do
  use MarketingbsmWeb, :live_component

  alias Tremorx.Components.Layout
  alias Tremorx.Components.Input
  alias Tremorx.Components.Text
  # alias Tremorx.Components.Select
  alias Tremorx.Components.Button

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <Text.title class="text-xl">
          <Text.bold><%= @title %></Text.bold>
        </Text.title>

        <Text.subtitle color="gray">
          Use this form to manage shop records in your database.
        </Text.subtitle>

        <Layout.divider class="my-4" />

        <.form :let={f} for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
          <%= if @form.source.type == :create do %>
            <Layout.col class="space-y-1.5">
              <label for="name_field">
                <Text.text class="text-tremor-content">
                  Shop Name
                </Text.text>
              </label>

              <Input.text_input
                id="name"
                name={@form[:name].name}
                placeholder="Shop Name..."
                type="text"
                field={@form[:name]}
                value={@form[:name].value}
                required="true"
              />
            </Layout.col>

            <Layout.col class="space-y-1.5">
              <label for="region[region_id]">
                <Text.text class="text-tremor-content">
                  Region Name
                </Text.text>
              </label>

              <Select.select
                id="region[:region_id]"
                name={@form[:region_id].name}
                placeholder="Select..."
                value={@form[:region_id].value}
                phx-update="ignore"
                required={true}
              >
                <:item :for={%{id: _id, name: name} <- @regions}>
                  <%= name %>
                </:item>
              </Select.select>
            </Layout.col>
          <% end %>

          <%= if @form.source.type == :update do %>
            <Layout.col class="space-y-1.5">
              <label for="name_field">
                <Text.text class="text-tremor-content">
                  Shop Name
                </Text.text>
              </label>

              <Input.text_input
                disabled
                id="name"
                name={@form[:name].name}
                placeholder="Shop Name..."
                type="text"
                field={@form[:name]}
                value={@form[:name].value}
                required="true"
              />
            </Layout.col>

            <Layout.col class="space-y-1.5">
              <label for="region[region_id]">
                <Text.text class="text-tremor-content">
                  Region Name
                </Text.text>
              </label>

              <Select.select
                id="region[:region_id]"
                name={@form[:region_id].name}
                placeholder="Select..."
                value={@form[:region_id].value}
                phx-update="ignore"
                required={true}
              >
                <:item :for={%{id: _id, name: name} <- @regions}>
                  <%= name %>
                </:item>
              </Select.select>
            </Layout.col>
          <% end %>

          <Button.button type="submit" size="xl" class="mt-2 w-min" phx-disable-with="Saving...">
            <%= if @form.source.type == :update do %>
              Update Shop
            <% else %>
              Create Shop
            <% end %>
          </Button.button>
        </.form>
      </Layout.col>
    </section>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> fetch_regions()
     |> assign_form()}
  end

  defp fetch_regions(socket) do
    query_results =
      Marketingbsm.Outlet.Region
      |> Ash.Query.load([])
      |> Ash.Query.sort(created_at: :desc)
      |> Ash.read!(page: [limit: 20])

    regions = Map.get(query_results, :results)

    socket |> assign(regions: regions)
  end

  @impl true
  def handle_event("validate", %{"shop" => shop_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, shop_params))}
  end

  def handle_event("save", %{"shop" => shop_params}, socket) do
    region_id =
      Enum.find_value(socket.assigns.regions, fn reg ->
        if reg.name == Map.get(shop_params, "region_id"), do: reg.id, else: nil
      end)

    shop_params =
      Map.merge(shop_params, %{
        "region_id" => region_id
      })

    case AshPhoenix.Form.submit(socket.assigns.form, params: shop_params) do
      {:ok, shop} ->
        notify_parent({:saved, shop})

        socket =
          socket
          |> put_flash(:info, "Shop #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, _form} ->
        {:noreply,
         socket
         |> put_flash(:error, "You are not authorized to perform this action")
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{shop: shop}} = socket) do
    form =
      if shop do
        AshPhoenix.Form.for_update(shop, :update_region,
          as: "shop",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Marketingbsm.Outlet.Shop, :new,
          as: "shop",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end

# ? what does tails by zach daniel do

# * well, tails is a tailwind class merger

# * lets take an Marketingbsm of this list hear that defines the italic classes

# * list = ["non-italic", "italic"]

# * Applying the classes function from tails:application

# ? +> will produce "italic"

#  this is because the classes define the same behaviour and hence the last one "italic" will be picked

# * Nothing too hard as you can see
