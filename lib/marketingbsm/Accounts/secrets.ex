defmodule Marketingbsm.Accounts.Secrets do
  use AshAuthentication.Secret

  # * AshAuthentication.Secret is a behaviour meaning you have to implement
  # * some functions in this case the secret_for function

  def secret_for([:authentication, :tokens, :signing_secret], Marketingbsm.Accounts.User, _) do
    case Application.fetch_env(:marketingbsm, MarketingbsmWeb.Endpoint) do
      {:ok, endpoint_config} ->
        Keyword.fetch(endpoint_config, :secret_key_base)

      :error ->
        :error
    end
  end
end
