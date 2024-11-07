defmodule Marketingbsm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MarketingbsmWeb.Telemetry,
      Marketingbsm.Repo,
      {DNSCluster, query: Application.get_env(:marketingbsm, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Marketingbsm.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Marketingbsm.Finch},
      # Start a worker by calling: Marketingbsm.Worker.start_link(arg)
      # {Marketingbsm.Worker, arg},
      # Start to serve requests, typically the last entry
      MarketingbsmWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Marketingbsm.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MarketingbsmWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
