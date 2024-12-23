defmodule MarketingbsmWeb.ReportLive.FormComponent do
  use MarketingbsmWeb, :live_component

  require Ash.Query

  alias Marketingbsm.ProjectGeneral

  alias MarketingbsmWeb.RegistryLive.FormComponent

  alias Marketingbsm.Record

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <Text.title class="text-xl">
          <Text.bold><%= @title %></Text.bold>
        </Text.title>

        <Text.subtitle color="gray">
          Use this form for your closing report .
        </Text.subtitle>

        <Layout.divider class="my-4" />

        <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Project Name
              </Text.text>
            </label>

            <Select.select
              id="project[:project_id]"
              name={@form[:project_id].name}
              placeholder="Select..."
              value={@form[:project_id].value}
              phx-update="ignore"
            >
              <:item :for={%{id: _id, name: name} <- @projects}>
                <%= name %>
              </:item>
            </Select.select>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_1)}>
              <.input field={@form[:field_1]} type="number" label={@result.field_1} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_2)}>
              <.input field={@form[:field_2]} type="number" label={@result.field_2} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_3)}>
              <.input field={@form[:field_3]} type="number" label={@result.field_3} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_4)}>
              <.input field={@form[:field_4]} type="number" label={@result.field_4} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_5)}>
              <.input field={@form[:field_5]} type="number" label={@result.field_5} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_6)}>
              <.input field={@form[:field_6]} type="number" label={@result.field_6} />
            </div>
          </Layout.col>
          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_7)}>
              <.input field={@form[:field_7]} type="number" label={@result.field_7} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_8)}>
              <.input field={@form[:field_8]} type="number" label={@result.field_8} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_9)}>
              <.input field={@form[:field_9]} type="number" label={@result.field_9} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_10)}>
              <.input field={@form[:field_10]} type="number" label={@result.field_10} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_11)}>
              <.input field={@form[:field_11]} type="number" label={@result.field_11} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_12)}>
              <.input field={@form[:field_12]} type="number" label={@result.field_12} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_13)}>
              <.input field={@form[:field_13]} type="number" label={@result.field_13} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_14)}>
              <.input field={@form[:field_14]} type="number" label={@result.field_14} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_15)}>
              <.input field={@form[:field_15]} type="number" label={@result.field_15} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_16)}>
              <.input field={@form[:field_16]} type="number" label={@result.field_16} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_17)}>
              <.input field={@form[:field_17]} type="number" label={@result.field_17} />
            </div>
          </Layout.col>
          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_18)}>
              <.input field={@form[:field_18]} type="number" label={@result.field_18} />
            </div>
          </Layout.col>
          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_19)}>
              <.input field={@form[:field_19]} type="number" label={@result.field_19} />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <div class={get_class(@result.field_20)}>
              <.input field={@form[:field_20]} type="number" label={@result.field_20} />
            </div>
          </Layout.col>

          <Button.button type="submit" size="xl" class="mt-2 w-min" phx-disable-with="Submitting...">
            Submit Report
          </Button.button>
        </.form>
      </Layout.col>
    </section>
    """
  end

  @impl true
  def update(assigns, socket) do
    result = %{
      field_1: "Choose Project Name",
      field_2: "Choose Project Name",
      field_3: "Choose Project Name",
      field_4: "Choose Project Name",
      field_5: "Choose Project Name",
      field_6: "Choose Project Name",
      field_7: "Choose Project Name",
      field_8: "Choose Project Name",
      field_9: "Choose Project Name",
      field_10: "Choose Project Name",
      field_11: "Choose Project Name",
      field_12: "Choose Project Name",
      field_13: "Choose Project Name",
      field_14: "Choose Project Name",
      field_15: "Choose Project Name",
      field_16: "Choose Project Name",
      field_17: "Choose Project Name",
      field_18: "Choose Project Name",
      field_19: "Choose Project Name",
      field_20: "Choose Project Name"
    }

    {:ok,
     socket
     |> assign(assigns)
     |> assign(result: result)
     |> fetch_projects_unfreezed()
     |> assign_form()}
  end

  def get_class(attribute) do
    if attribute == nil, do: "hidden"
  end

  @impl true
  def handle_event("validate", %{"report" => report_params}, socket) do
    project_id = FormComponent.get_project_id(socket, report_params)

    result = ProjectGeneral.get_template_by_project_id!(project_id)

    {:noreply,
     socket
     #  |> assign(form: AshPhoenix.Form.validate(socket.assigns.form, report_params))
     |> assign(result: result)}
  end

  def handle_event("save", %{"report" => report_params}, socket) do
    id = socket.assigns.current_user

    case Record.get_user_by_id(id) do
      {:ok, registry} ->
        ambassador_id = registry.ambassador_id
        outlet_id = registry.outlet_id
        project_id = FormComponent.get_project_id(socket, report_params)

        report_params =
          Map.merge(report_params, %{
            "ambassador_id" => ambassador_id,
            "project_id" => project_id,
            "outlet_id" => outlet_id
          })

        report_params = get_complete_params(report_params)

        if project_id == registry.project_id do
          case AshPhoenix.Form.submit(socket.assigns.form, params: report_params) do
            {:ok, _report} ->
              user_params = %{days_worked: registry.days_worked + 1}

              Marketingbsm.Record.update_ambassador(registry, user_params,
                actor: socket.assigns.current_user
              )

              socket =
                socket
                |> put_flash(:info, "Your Report has been received successfully")
                |> push_patch(to: socket.assigns.patch)

              {:noreply, socket}

            {:error, form} ->
              {:noreply, assign(socket, form: form)}
          end
        else
          {:noreply,
           socket
           |> push_patch(to: socket.assigns.patch)
           |> put_flash(:error, "Report Not Submitted!! Please enter the correct details")}
        end

      {:error, _error} ->
        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)
         |> put_flash(:error, "Report Not Submitted!! You are not scheduled to activate")}
    end
  end

  def get_complete_params(params) do
    new_map = Map.drop(params, ["ambassador_id", "outlet_id", "project_id"])

    new_map = Enum.filter(new_map, fn {_key, value} -> value != "" end)
    list_num = Enum.map(new_map, fn {_k, v} -> v end)

    list_final = Enum.map(list_num, fn x -> String.to_integer(x) end)
    total_sales = Enum.sum(list_final)

    new_map = %{"total_sales" => total_sales}

    Map.merge(params, new_map)
  end

  defp assign_form(%{assigns: %{report: report}} = socket) do
    form =
      if report do
        AshPhoenix.Form.for_update(report, :update,
          as: "report",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Marketingbsm.Record.Report, :create,
          as: "report",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def fetch_projects_unfreezed(socket) do
    query_results =
      Marketingbsm.ProjectGeneral.Project
      |> Ash.Query.load([])
      |> Ash.Query.filter(is_freezed: false)
      |> Ash.read!(page: [limit: 20])

    projects = Map.get(query_results, :results)

    socket |> assign(projects: projects)
  end
end

# Phoenix.HTML.FormField
# uses the Access behaviour => data[key]
#* <.input field={@form[:field_1]} type="number" label={@result.field_1} />
# which is used to retrieve the input name, id, and values.
# without the field assign, you would have to input name, value fields explicitly like this :

#* <.input name={"kerware"} value={"jeans"} type="number" label={@result.field_1} />
