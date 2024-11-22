defmodule MarketingbsmWeb.TemplateLive.Index do
  use MarketingbsmWeb, :live_view

  alias Marketingbsm.ProjectGeneral

  alias Tremorx.Theme

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full">
      <Layout.flex align_items="start" class="h-screen overflow-y-hidden">
        <%= live_render(@socket, MarketingbsmWeb.LiveDrawer,
          session: %{
            "active_tab" => "template",
            "hiderr" => @hiderr,
            "user" => "user?id=#{@current_user.id}"
          },
          id: "live_drawer",
          sticky: true
        ) %>

        <Layout.flex
          flex_direction="col"
          align_items="start"
          justify_content="start"
          class="flex-1 px-8 py-8 h-full overflow-y-auto bg-gray-50/75"
        >
          <Layout.flex justify_content="between" class="">
            <Layout.flex flex_direction="col" align_items="start" class="grow">
              <div class="ml-4">
                <.link phx-click={JS.push("close")}>
                  <.icon
                    class={
                      Tails.classes([
                        Theme.get_sizing_style("xl", "height"),
                        Theme.get_sizing_style("xl", "width")
                      ])
                    }
                    name="hero-bars-3-solid"
                  />
                </.link>
              </div>
              <Text.title class="text-xl">
                <Text.bold>Reporting Templates</Text.bold>
              </Text.title>

              <Text.subtitle color="gray">
                Templates define how the Brand Ambassadors are going to Report Sales
              </Text.subtitle>
            </Layout.flex>

            <Button.button size="xl" phx-click={JS.patch(~p"/templates/new")}>
              <:icon>
                <.icon name="hero-plus" />
              </:icon>
              Create Template
            </Button.button>
          </Layout.flex>

          <Table.table class="w-full">
            <Table.table_head class="rounded-t-md border-b-[1px]">
              <Table.table_row class="hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted">
                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Project Name
                  </Text.text>
                </Table.table_cell>
                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 1
                  </Text.text>
                </Table.table_cell>
                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 2
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 3
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 4
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 5
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 6
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 7
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 8
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 9
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 10
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 11
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 12
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 13
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 14
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 15
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 16
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 17
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 18
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 19
                  </Text.text>
                </Table.table_cell>

                <Table.table_cell>
                  <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                    Field 20
                  </Text.text>
                </Table.table_cell>
              </Table.table_row>
            </Table.table_head>

            <Table.table_body
              id="table_stream_outlets"
              phx-update="stream"
              class="divide-y overflow-y-auto"
            >
              <Table.table_row
                :for={{dom_id, template} <- @streams.templates}
                id={"#{dom_id}"}
                class="group hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted"
              >
                <Table.table_cell>
                  <%= ProjectGeneral.get_project_by_id!(template.project_id).name %>
                </Table.table_cell>
                <Table.table_cell>
                  <%= template.field_1 %>
                </Table.table_cell>
                <Table.table_cell>
                  <%= template.field_2 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_3 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_4 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_5 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_6 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_7 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_8 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_9 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_10 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_11 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_12 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_13 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_14 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_15 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_16 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_17 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_18 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_19 %>
                </Table.table_cell>

                <Table.table_cell>
                  <%= template.field_20 %>
                </Table.table_cell>
              </Table.table_row>
            </Table.table_body>
          </Table.table>

          <.modal
            :if={@live_action in [:new, :edit]}
            id="label-modal"
            show
            on_cancel={JS.patch(~p"/templates")}
          >
            <.live_component
              module={MarketingbsmWeb.TemplateLive.FormComponent}
              id={(@template && @template.project_id) || :new}
              title={@page_title}
              current_user={@current_user}
              action={@live_action}
              template={@template}
              patch={~p"/templates"}
            />
          </.modal>
        </Layout.flex>
      </Layout.flex>
    </div>
    """
  end

  @impl true

  def mount(_params, _session, socket) do
    socket = socket |> assign(:hiderr, "")
    {:ok, stream(socket, :templates, ProjectGeneral.list_templates!())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"project_id" => project_id}) do
    socket
    |> assign(:page_title, "Edit Label")
    |> assign(
      :template,
      Ash.get!(Marketingbsm.ProjectGeneral.Template, project_id,
        actor: socket.assigns.current_user
      )
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Reporting Template")
    |> assign(:template, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Reporting Templates")
    |> assign(:template, nil)
  end

  @impl true
  def handle_info({MarketingbsmWeb.TemplateLive.FormComponent, {:saved, template}}, socket) do
    {:noreply, stream_insert(socket, :templates, template)}
  end

  @impl true
  def handle_event("close", _params, socket) do
    Phoenix.PubSub.broadcast(
      Marketingbsm.PubSub,
      "#{socket.assigns.current_user.id}",
      {:close_modal}
    )

    {:noreply, socket}
  end
end
