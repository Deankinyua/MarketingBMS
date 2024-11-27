defmodule Marketingbsm.Checks.IsAdmin do
  alias Marketingbsm.Management
  use Ash.Policy.SimpleCheck

  # This is used when logging a breakdown of how a policy is applied - see Logging below.
  def describe(_) do
    "actor is a project admin"
  end

  # The context here may have a changeset, query, resource, and domain module, depending
  # on the action being run.
  # `match?` should return true or false, and answer the statement being posed in the description,
  # i.e "is the actor a project manager?"

  # * match?(actor, context, options)

  def match?(actor, _context, _opts) do
    case Management.get_manager(actor.id) do
      {:ok, _result} ->
        true

      {:error, _error} ->
        false
    end
  end

  def match?(_, _, _), do: false
end

# Management.get_manager("2c2fcab5-70ea-4b77-999a-1f257f2adfb3")
