defmodule Marketingbsm.ProjectGeneral.Project do
  alias Marketingbsm.Checks.IsAdmin

  use Ash.Resource,
    domain: Marketingbsm.ProjectGeneral,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  resource do
    description """
    Represents project. A project has a name and an id
    The Organization can run multiple projects concurrently.
    """

    plural_name :projects
    short_name :project
  end

  postgres do
    repo Marketingbsm.Repo
    table "projects"
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      description "The name of the project"
      allow_nil? false
    end

    attribute :is_freezed, :boolean, default: false, allow_nil?: false
  end

  actions do
    # https://hexdocs.pm/ash/dsl-ash-resource.html#actions

    defaults [:create, :read, :update, :destroy]

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true

      filter expr(id == ^arg(:id))
    end

    create :new do
      accept [
        :name,
        :is_freezed
      ]

      # Whether or not this action should be used when no action is specified by the caller.

      primary? true

      description "This action creates a new project and only accepts a name"
    end

    read :default_read do
      primary? true

      pagination offset?: true, keyset?: true, required?: false
    end

    update :update_project do
      accept [:name, :is_freezed]
      primary? true
    end

    destroy :soft_delete do
      primary? true
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if IsAdmin
    end

    policy action_type(:update) do
      authorize_if IsAdmin
    end

    policy action_type(:destroy) do
      authorize_if IsAdmin
    end
  end
end
