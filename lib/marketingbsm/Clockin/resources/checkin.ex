defmodule Marketingbsm.Clockin.Checkin do
  alias Marketingbsm.Checks.IsAdminLeader

  use Ash.Resource,
    # Tells Ash where the generated code interface belongs
    domain: Marketingbsm.Clockin,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  resource do
    description """
    Use this resource to handle image urls that will be used to pull the ambassadors' images
    from MinIO
    """

    plural_name :checkins
    short_name :checkin
  end

  postgres do
    table "checkins"
    repo Marketingbsm.Repo

    references do
      reference :project, on_delete: :delete
      reference :outlet, on_delete: :delete
    end
  end

  # Attributes are simple pieces of data that exist in your resource
  attributes do
    uuid_primary_key :id

    attribute :ambassador_id, :uuid do
      allow_nil? false
    end

    attribute :project_id, :uuid do
      allow_nil? false
    end

    attribute :outlet_id, :uuid do
      allow_nil? false
    end

    attribute :file, Marketingbsm.File do
      description "The check-in picture"

      allow_nil? false
    end

    create_timestamp :create_date do
      writable? false
      default &Date.utc_today/0
      match_other_defaults? true
      update_default &Date.utc_today/0
      type Ash.Type.Date
      allow_nil? false
    end

    create_timestamp :create_time do
      writable? false
      default &Time.utc_now/0
      match_other_defaults? true
      update_default &Time.utc_now/0
      type Ash.Type.Time
      allow_nil? false
    end
  end

  actions do
    # Exposes default built in actions to manage the resource
    defaults [:read, :destroy]

    create :create do
      # * accept behaves like cast/3 in ecto changesets
      accept [
        :outlet_id,
        :project_id,
        :ambassador_id,
        :file
      ]
    end

    update :update do
      # * accept behaves like cast/3 in ecto changesets

      accept [
        :file
      ]
    end

    read :by_id do
      argument :ambassador_id, :uuid, allow_nil?: false
      argument :create_date, :date, allow_nil?: false
      # Tells us we expect this action to return a single result
      get? true
      # Filters the `:id` given in the argument
      # against the `id` of each element in the resource
      filter expr(ambassador_id == ^arg(:ambassador_id))
      # filter expr(create_date == ^arg(:create_date))
      filter expr(create_date == ^arg(:create_date))
    end
  end

  relationships do
    # relationship_type - relationship_name - destination_resource
    belongs_to :project, Marketingbsm.ProjectGeneral.Project do
      attribute_writable? true
    end

    belongs_to :outlet, Marketingbsm.Outlet.Shop do
      attribute_writable? true
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if always()
    end

    policy action_type(:update) do
      authorize_if IsAdminLeader
    end

    policy action_type(:destroy) do
      authorize_if IsAdminLeader
    end
  end
end
