defmodule Marketingbsm.Management.ProjectManager do
  use Ash.Resource,
    # Tells Ash where the generated code interface belongs
    domain: Marketingbsm.Management,
    data_layer: AshPostgres.DataLayer

  resource do
    description """
    Represents the Project managers
    Handles the Sensitive information belonging to a Project managers
    """

    plural_name :managers
    short_name :manager
  end

  postgres do
    table "managers"
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
end
