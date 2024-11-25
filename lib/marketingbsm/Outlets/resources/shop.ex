defmodule Marketingbsm.Outlet.Shop do
  use Ash.Resource,
    domain: Marketingbsm.Outlet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  resource do
    description """
    Represents a Shop. A Shop belongs to a Region
    """

    plural_name :shops
    short_name :shop
  end

  postgres do
    repo Marketingbsm.Repo
    table "shops"

    references do
      reference :region, on_delete: :delete
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      description "The name of the region"
      allow_nil? false
    end

    attribute :region_id, :uuid do
      allow_nil? false

      description "The Region this Shop belongs to"
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true

      filter expr(id == ^arg(:id))
    end

    create :new do
      accept [
        :name,
        :region_id
      ]

      primary? true
    end

    read :default_read do
      primary? true

      pagination offset?: true, keyset?: true, required?: false
    end

    update :update_region do
      accept [:name, :region_id]
      primary? true
    end

    destroy :soft_delete do
      primary? true
    end
  end

  relationships do
    # relationship_type - relationship_name - destination_resource
    belongs_to :region, Marketingbsm.Outlet.Region do
      attribute_writable? true
    end
  end
end
