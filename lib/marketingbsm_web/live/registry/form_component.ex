defmodule MarketingbsmWeb.RegistryLive.FormComponent do
  use MarketingbsmWeb, :live_component

  import MarketingbsmWeb.ReportLive.FormComponent,
    only: [fetch_outlets: 1]

  import MarketingbsmWeb.TemplateLive.FormComponent, only: [fetch_projects: 1]

  alias Marketingbsm.Accounts
  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <Text.title class="text-xl">
          <Text.bold><%= @title %></Text.bold>
        </Text.title>

        <Text.subtitle color="gray">
          Use this form to manage the Brand Ambassadors who should activate
        </Text.subtitle>

        <Layout.divider class="my-4" />

        <.simple_form
          for={@form}
          id="registry-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <%= if @form.source.type == :create do %>
            <Layout.col class="space-y-1.5">
              <label for="ambassador[:ambassador_id]">
                <Text.text class="text-tremor-content">
                  Ambassador Name
                </Text.text>
              </label>

              <Select.search_select
                id="ambassador[:ambassador_id]"
                name={@form[:ambassador_id].name}
                placeholder="Select..."
                value={@form[:ambassador_id].value}
                phx-update="ignore"
                required={true}
              >
                <:item :for={%{id: _id, name: name} <- @ambassadors}>
                  <%= name %>
                </:item>
              </Select.search_select>
            </Layout.col>

            <Layout.col class="space-y-1.5">
              <label for="outlet[:outlet_id]">
                <Text.text class="text-tremor-content">
                  Outlet Name
                </Text.text>
              </label>

              <Select.search_select
                id="outlet[:outlet_id]"
                name={@form[:outlet_id].name}
                placeholder="Select..."
                value={@form[:outlet_id].value}
                phx-update="ignore"
                required={true}
              >
                <:item :for={%{id: _id, name: name} <- @outlets}>
                  <%= name %>
                </:item>
              </Select.search_select>
            </Layout.col>

            <Layout.col class="space-y-1.5">
              <label for="project[:project_id]">
                <Text.text class="text-tremor-content">
                  Project Name
                </Text.text>
              </label>

              <Select.search_select
                id="project[:project_id]"
                name={@form[:project_id].name}
                placeholder="Select..."
                value={@form[:project_id].value}
                phx-update="ignore"
                required={true}
              >
                <:item :for={%{id: _id, name: name} <- @projects}>
                  <%= name %>
                </:item>
              </Select.search_select>
            </Layout.col>
          <% end %>
          <%= if @form.source.type == :update do %>
            <.input
              field={@form[:should_activate]}
              type="select"
              options={@activate_selector}
              label="Should Activate"
            />
          <% end %>

          <Button.button type="submit" size="xl" class="mt-2 w-min" phx-disable-with="Saving...">
            <%= if @form.source.type == :update do %>
              Update Registry
            <% else %>
              Create Registry
            <% end %>
          </Button.button>
        </.simple_form>
      </Layout.col>
    </section>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> fetch_promoters()
     |> fetch_projects()
     |> fetch_outlets()
     |> activate_selector()
     |> assign_form()}
  end

  defp activate_selector(socket) do
    socket |> assign(activate_selector: [true, false])
  end

  defp fetch_promoters(socket) do
    query_results =
      Marketingbsm.Activation.Ambassador
      |> Ash.Query.load([])
      |> Ash.read!(page: [limit: 20])

    ambassadors = Map.get(query_results, :results)

    dbg(ambassadors)

    socket |> assign(ambassadors: ambassador_selector(ambassadors))
  end

  @impl true
  def handle_event("validate", %{"registry" => registry_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, registry_params))}
  end

  def handle_event("save", %{"registry" => registry_params}, socket) do
    ambassador_id = get_ambassador_id(socket, registry_params)

    outlet_id = get_outlet_id(socket, registry_params)

    project_id = get_project_id(socket, registry_params)

    registry_params =
      Map.merge(registry_params, %{
        "ambassador_id" => ambassador_id,
        "project_id" => project_id,
        "outlet_id" => outlet_id
      })

    case AshPhoenix.Form.submit(socket.assigns.form, params: registry_params) do
      {:ok, registry} ->
        notify_parent({:saved, registry})

        socket =
          socket
          |> put_flash(:info, "Registry #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{registry: registry}} = socket) do
    form =
      if registry do
        AshPhoenix.Form.for_update(registry, :update,
          as: "registry",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Marketingbsm.Record.Registry, :create,
          as: "registry",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def ambassador_selector(ambassadors) do
    for item <- ambassadors do
      user = Accounts.get_user_by_id!(item.id)

      user
    end
  end

  def get_project_id(socket, params) do
    project_id =
      Enum.find_value(socket.assigns.projects, fn proj ->
        if proj.name == Map.get(params, "project_id"), do: proj.id, else: nil
      end)

    project_id
  end

  def get_outlet_id(socket, params) do
    outlet_id =
      Enum.find_value(socket.assigns.outlets, fn out ->
        if out.name == Map.get(params, "outlet_id"), do: out.id, else: nil
      end)

    outlet_id
  end

  def get_ambassador_id(socket, params) do
    ambassador_id =
      Enum.find_value(socket.assigns.ambassadors, fn amb ->
        if amb.name == Map.get(params, "ambassador_id"), do: amb.id, else: nil
      end)

    ambassador_id
  end
end
