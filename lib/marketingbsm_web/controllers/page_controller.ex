defmodule MarketingbsmWeb.PageController do
  use MarketingbsmWeb, :controller

  # def home(conn, _params) do
  #   # The home page is often custom made,
  #   # so skip the default app layout.
  #   render(conn, :home, layout: false)
  # end

  def home(conn, _params) do
    port = System.get_env("PORT")
    access_key_id = System.get_env("S3_ACCESS_KEY_ID")
    IO.puts("The application is running on port: #{port}")
    IO.puts("The access key id is : #{access_key_id}")

    if conn.assigns.current_user do
      redirect(conn, to: "/outlets")
    else
      redirect(conn, to: "/sign-in")
    end
  end
end
