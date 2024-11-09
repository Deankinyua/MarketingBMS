defmodule Marketingbsm.ProjectGeneral do
  use Ash.Domain

  domain do
    description """
    This Domain holds All the project id's and names
    and also holds the details for making the reporting template
    """
  end

  resources do
    resource Marketingbsm.ProjectGeneral.Project do
      # Define an interface for calling resource actions.
      # We use the Function when we executing code
      # <Function> <Action>
      define :add_project, action: :create
      define :update_project, action: :update
      define :get_project_by_id, args: [:id], action: :by_id
    end

    resource Marketingbsm.ProjectGeneral.Label do
      # Define an interface for calling resource actions.
      # We use the Function when we executing code
      # <Function> <Action>
      define :add_label, action: :create
      define :update_label, action: :update
      define :list_templates, action: :read
      define :get_template_by_project_id, args: [:project_id], action: :by_id
    end
  end
end
