defmodule Marketingbsm.Outlet.Region do
  alias Marketingbsm.Checks.IsAdmin

  use Ash.Resource,
    domain: Marketingbsm.Outlet,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  resource do
    description """
    Represents a region. A Region can hold many outlets
    """

    plural_name :regions
    short_name :region
  end

  postgres do
    repo Marketingbsm.Repo
    table "regions"
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      description "The name of the region"
      allow_nil? false
    end

    create_timestamp :created_at
    update_timestamp :updated_at
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
        :name
      ]

      # Whether or not this action should be used when no action is specified by the caller.

      primary? true

      description "This action creates a new region and only accepts a name"
    end

    read :default_read do
      primary? true

      pagination offset?: true, keyset?: true, required?: false
    end

    update :update_region do
      accept [:name]
      primary? true
    end

    destroy :soft_delete do
      primary? true
    end
  end

  relationships do
    has_many :shops, Marketingbsm.Outlet.Shop
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if IsAdmin
    end

    policy action_type(:destroy) do
      authorize_if IsAdmin
    end
  end
end
