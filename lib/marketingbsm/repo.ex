defmodule Marketingbsm.Repo do
  use AshPostgres.Repo, otp_app: :marketingbsm

  def installed_extensions do
    ["uuid-ossp", "citext", "ash-functions"]
  end
end
