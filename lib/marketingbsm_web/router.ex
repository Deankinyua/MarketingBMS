defmodule MarketingbsmWeb.Router do
  use MarketingbsmWeb, :router

  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MarketingbsmWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/", MarketingbsmWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/sign-in", SignInPage
    live "/register", RegisterPage

    # auth code
    sign_out_route(AuthController)
    auth_routes_for(Marketingbsm.Accounts.User, to: AuthController)

    ash_authentication_live_session :authentication_optional,
      on_mount: {MarketingbsmWeb.LiveUserAuth, :live_no_user} do
    end

    ash_authentication_live_session :authentication_required,
      on_mount: {MarketingbsmWeb.LiveUserAuth, :live_user_required} do
      live "/regions", RegionLive.Index, :index
      live "/regions/new", RegionLive.Index, :new
      live "/regions/:id/edit", RegionLive.Index, :edit

      live "/regions/:id", RegionLive.Show, :show
      live "/regions/:id/show/edit", RegionLive.Show, :edit

      live "/outlets", ShopLive.Index, :index
      live "/outlets/new", ShopLive.Index, :new
      live "/outlets/:id/edit", ShopLive.Index, :edit

      live "/ambassadors", AmbassadorLive.Index, :index
      live "/ambassadors/new", AmbassadorLive.Index, :new
      live "/ambassadors/:id/edit", AmbassadorLive.Index, :edit

      live "/projects", ProjectLive.Index, :index
      live "/projects/new", ProjectLive.Index, :new
      live "/projects/:id/edit", ProjectLive.Index, :edit

      live "/projects/:id", ProjectLive.Show, :show
      live "/projects/:id/show/edit", ProjectLive.Show, :edit

      live "/templates", TemplateLive.Index, :index
      live "/templates/new", TemplateLive.Index, :new
      live "/templates/:id/edit", TemplateLive.Index, :edit

      live "/templates/:id", TemplateLive.Show, :show
      live "/templates/:id/show/edit", TemplateLive.Show, :edit

      live "/registries", RegistryLive.Index, :index
      live "/registries/new", RegistryLive.Index, :new
      live "/registries/:id/edit", RegistryLive.Index, :edit

      live "/registries/:id", RegistryLive.Show, :show
      live "/registries/:id/show/edit", RegistryLive.Show, :edit

      live "/reports", ReportLive.Index, :index
      live "/reports/new", ReportLive.Index, :new
      live "/reports/:id/edit", ReportLive.Index, :edit

      live "/reports/:id", ReportLive.Show, :show
      live "/reports/:id/show/edit", ReportLive.Show, :edit

      live "/checkins", CheckinLive.Index, :index
      live "/checkins/new", CheckinLive.Index, :new
      live "/checkins/:id/edit", CheckinLive.Index, :edit

      live "/checkins/:id", CheckinLive.Show, :show
      live "/checkins/:id/show/edit", CheckinLive.Show, :edit

      live "/checkouts", CheckoutLive.Index, :index
      live "/checkouts/new", CheckoutLive.Index, :new
      live "/checkouts/:id/edit", CheckoutLive.Index, :edit

      live "/checkouts/:id", CheckoutLive.Show, :show
      live "/checkouts/:id/show/edit", CheckoutLive.Show, :edit

      live "/summary", SummaryLive.Index, :index
      live "/summary/new", SummaryLive.Index, :new
      live "/summary/:id/edit", SummaryLive.Index, :edit

      live "/summary/:id", SummaryLive.Show, :show
      live "/summary/:id/show/edit", SummaryLive.Show, :edit

      live "/management", ManagementLive.Index, :index
      live "/management/new", ManagementLive.Index, :new
      live "/management/:id/edit", ManagementLive.Index, :edit

      live "/management/:id", ManagementLive.Show, :show
      live "/management/:id/show/edit", ManagementLive.Show, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", MarketingbsmWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:marketingbsm, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MarketingbsmWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
