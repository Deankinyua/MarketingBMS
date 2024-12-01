defmodule Marketingbsm.Management.TeamLeader do
  alias Marketingbsm.Checks.IsAdmin

  use Ash.Resource,
    # Tells Ash where the generated code interface belongs
    domain: Marketingbsm.Management,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  resource do
    description """
    Represents the Team leaders
    Handles the Sensitive information belonging to a Team leaders
    """

    plural_name :leaders
    short_name :leader
  end

  postgres do
    table "leaders"
    repo Marketingbsm.Repo
  end

  attributes do
    attribute :id, :uuid do
      allow_nil? false
      primary_key? true
    end
  end

  actions do
    # Exposes default built in actions to manage the resource
    defaults [:read, :destroy]

    create :create do
      # accept name as input
      # * accept behaves like cast/3 in ecto changesets
      accept [:id]
    end

    # Defines custom read action which fetches post by id.
    read :by_id do
      # This action has one argument :id of type :uuid
      argument :id, :uuid, allow_nil?: false
      # Tells us we expect this action to return a single result
      get? true
      # Filters the `:id` given in the argument
      # against the `id` of each element in the resource
      filter expr(id == ^arg(:id))
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
