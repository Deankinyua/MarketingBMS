defmodule MarketingbsmWeb.PageController do
  use MarketingbsmWeb, :controller

  # def home(conn, _params) do
  #   # The home page is often custom made,
  #   # so skip the default app layout.
  #   render(conn, :home, layout: false)
  # end

  def home(conn, _params) do
    if conn.assigns.current_user do
      dbg(conn)
      redirect(conn, to: "/outlets")
    else
      redirect(conn, to: "/sign-in")
    end
  end
end
