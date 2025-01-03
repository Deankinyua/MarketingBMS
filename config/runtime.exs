import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/marketingbsm start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :marketingbsm, MarketingbsmWeb.Endpoint, server: true
end

if config_env() == :prod do
  # database_url =
  #   System.get_env("DATABASE_URL") ||
  #     raise """
  #     environment variable DATABASE_URL is missing.
  #     For example: ecto://USER:PASS@HOST/DATABASE
  #     """

  db_database = System.get_env("DATABASE_DB") || "marketingbsm"
  db_username = System.get_env("DATABASE_USER") || "postgres"
  db_password = System.get_env("DATABASE_PASSWORD") || "postgres"
  db_url = "ecto://#{db_username}:#{db_password}@localhost/#{db_database}"

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :marketingbsm, Marketingbsm.Repo,
    # ssl: true,
    url: db_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  access_key_id =
    System.get_env("S3_ACCESS_KEY_ID") ||
      raise """
      environment variable S3_ACCESS_KEY_ID is missing.
      This is required for file uploads
      """

  secret_access_key =
    System.get_env("S3_SECRET_ACCESS_KEY") ||
      raise """
      environment variable S3_SECRET_ACCESS_KEY is missing.
      This is required for file uploads
      """

  bucket =
    System.get_env("S3_BUCKET") ||
      raise """
      environment variable S3_BUCKET is missing.
      This is required for file uploads
      """

  region =
    System.get_env("S3_REGION") ||
      raise """
      environment variable S3_REGION is missing.
      This is required for file uploads
      """

  s3_host =
    System.get_env("S3_HOST") ||
      raise """
      environment variable S3_HOST is missing.
      This is required for file uploads
      """

  s3_port =
    System.get_env("S3_PORT") ||
      raise """
      environment variable S3_PORT is missing.
      This is required for file uploads
      """

  scheme =
    System.get_env("S3_SCHEME") ||
      raise """
      environment variable S3_SCHEME is missing.
      This is required for file uploads
      """

  config :ex_aws,
    region: region,
    access_key_id: access_key_id,
    secret_access_key: secret_access_key

  config :ex_aws, :s3,
    scheme: scheme,
    host: s3_host,
    port: s3_port

  import Config
  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "localhost"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :marketingbsm, MarketingbsmWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    check_origin: ["http://13.48.254.182:9484"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: 9484
    ],
    secret_key_base: secret_key_base

  config :marketingbsm, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")
end
