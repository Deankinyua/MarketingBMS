defmodule Marketingbsm.Management do
  use Ash.Domain

  domain do
    description """
    This Domain holds Resources related to the Management.
    Management includes project managers, team leaders.
    """
  end

  resources do
    resource Marketingbsm.Management.ProjectManager do
      # Define an interface for calling resource actions.
      # We use the Function when we executing code
      # <Function> <Action>
      define :create_manager, action: :create
      define :list_managers, action: :read
      define :get_manager, args: [:id], action: :by_id
      define :destroy_manager, action: :destroy
    end
  end

  resources do
    resource Marketingbsm.Management.TeamLeader do
      # Define an interface for calling resource actions.
      # We use the Function when we executing code
      # <Function> <Action>
      define :create_leader, action: :create
      define :list_leaders, action: :read
      define :get_leader, args: [:id], action: :by_id
      define :destroy_leader, action: :destroy
    end
  end
end
