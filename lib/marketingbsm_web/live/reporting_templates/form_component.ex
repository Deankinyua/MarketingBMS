defmodule MarketingbsmWeb.TemplateLive.FormComponent do
  use MarketingbsmWeb, :live_component

  alias MarketingbsmWeb.RegistryLive.FormComponent
  alias Marketingbsm.ProjectGeneral

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <Text.title class="text-xl">
          <Text.bold><%= @title %></Text.bold>
        </Text.title>

        <Text.subtitle color="gray">
          Use this form to Make Reporting Templates For Respective Projects.
        </Text.subtitle>

        <Layout.divider class="my-4" />

        <.form :let={f} for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
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

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 1
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_1].name}
              placeholder="Field 1..."
              type="text"
              field={f[:field_1]}
              value={f[:field_1].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 2
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_2].name}
              placeholder="Field 2..."
              type="text"
              field={f[:field_2]}
              value={f[:field_2].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 3
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_3].name}
              placeholder="Field 3..."
              type="text"
              field={f[:field_3]}
              value={f[:field_3].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 4
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_4].name}
              placeholder="Field 4..."
              type="text"
              field={f[:field_4]}
              value={f[:field_4].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 5
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_5].name}
              placeholder="Field 5..."
              type="text"
              field={f[:field_5]}
              value={f[:field_5].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 6
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_6].name}
              placeholder="Field 6..."
              type="text"
              field={f[:field_6]}
              value={f[:field_6].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 7
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_7].name}
              placeholder="Field 7..."
              type="text"
              field={f[:field_7]}
              value={f[:field_7].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 8
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_8].name}
              placeholder="Field 8..."
              type="text"
              field={f[:field_8]}
              value={f[:field_8].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 9
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_9].name}
              placeholder="Field 9..."
              type="text"
              field={f[:field_9]}
              value={f[:field_9].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 10
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_10].name}
              placeholder="Field 10..."
              type="text"
              field={f[:field_10]}
              value={f[:field_10].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 11
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_11].name}
              placeholder="Field 11..."
              type="text"
              field={f[:field_11]}
              value={f[:field_11].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 12
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_12].name}
              placeholder="Field 12..."
              type="text"
              field={f[:field_12]}
              value={f[:field_12].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 13
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_13].name}
              placeholder="Field 13..."
              type="text"
              field={f[:field_13]}
              value={f[:field_13].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 14
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_14].name}
              placeholder="Field 14..."
              type="text"
              field={f[:field_14]}
              value={f[:field_14].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 15
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_15].name}
              placeholder="Field 15..."
              type="text"
              field={f[:field_15]}
              value={f[:field_15].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 16
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_16].name}
              placeholder="Field 16..."
              type="text"
              field={f[:field_16]}
              value={f[:field_16].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 17
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_17].name}
              placeholder="Field 17..."
              type="text"
              field={f[:field_17]}
              value={f[:field_17].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 18
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_18].name}
              placeholder="Field 18..."
              type="text"
              field={f[:field_18]}
              value={f[:field_18].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 19
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_19].name}
              placeholder="Field 19..."
              type="text"
              field={f[:field_19]}
              value={f[:field_19].value}
            />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label>
              <Text.text class="text-tremor-content mt-2 mb-3 text-bold">
                Field 20
              </Text.text>
            </label>

            <Input.text_input
              name={f[:field_20].name}
              placeholder="Field 20..."
              type="text"
              field={f[:field_20]}
              value={f[:field_20].value}
            />
          </Layout.col>

          <Button.button type="submit" size="xl" class="mt-2 w-min" phx-disable-with="Saving...">
            Create Template
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
     |> fetch_projects()
     |> assign_form()}
  end

  def fetch_projects(socket) do
    query_results =
      Marketingbsm.ProjectGeneral.Project
      |> Ash.Query.load([])
      |> Ash.read!(page: [limit: 20])

    projects = Map.get(query_results, :results)

    socket |> assign(projects: projects)
  end

  @impl true
  def handle_event("validate", %{"template" => template_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, template_params))}
  end

  def handle_event("save", %{"template" => template_params}, socket) do
    dbg(template_params)

    project_id = FormComponent.get_project_id(socket, template_params)

    case ProjectGeneral.get_template_by_project_id(project_id) do
      {:ok, template} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "Reporting template already exists"
         )
         |> push_patch(to: "/templates")}

      {:error, error} ->
        template_params =
          Map.merge(template_params, %{
            "project_id" => project_id
          })

        case AshPhoenix.Form.submit(socket.assigns.form, params: template_params) do
          {:ok, template} ->
            notify_parent({:saved, template})

            socket =
              socket
              |> put_flash(
                :info,
                "Reporting Template #{socket.assigns.form.source.type}d successfully"
              )
              |> push_patch(to: socket.assigns.patch)

            {:noreply, socket}

          {:error, form} ->
            {:noreply, assign(socket, form: form)}
        end
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{template: template}} = socket) do
    form =
      if template do
        AshPhoenix.Form.for_update(template, :update,
          as: "template",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Marketingbsm.ProjectGeneral.Template, :create,
          as: "template",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
