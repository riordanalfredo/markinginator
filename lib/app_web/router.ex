defmodule AppWeb.Router do
  use AppWeb, :router

  import AppWeb.TeacherAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_teacher
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AppWeb do
    pipe_through :browser

    get "/", PageController, :home

  end

  # Other scopes may use custom stacks.
  # scope "/api", AppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AppWeb do
    pipe_through [:browser, :redirect_if_teacher_is_authenticated]

    live_session :redirect_if_teacher_is_authenticated,
      on_mount: [{AppWeb.TeacherAuth, :redirect_if_teacher_is_authenticated}] do
      live "/teachers/register", TeacherRegistrationLive, :new
      live "/teachers/log_in", TeacherLoginLive, :new
      live "/teachers/reset_password", TeacherForgotPasswordLive, :new
      live "/teachers/reset_password/:token", TeacherResetPasswordLive, :edit
    end

    post "/teachers/log_in", TeacherSessionController, :create
  end

  scope "/", AppWeb do
    pipe_through [:browser, :require_authenticated_teacher]

    live_session :require_authenticated_teacher,
      on_mount: [{AppWeb.TeacherAuth, :ensure_authenticated}] do
      live "/teachers/settings", TeacherSettingsLive, :edit
      live "/teachers/settings/confirm_email/:token", TeacherSettingsLive, :confirm_email
    end
  end

  scope "/", AppWeb do
    pipe_through [:browser]

    delete "/teachers/log_out", TeacherSessionController, :delete

    live_session :current_teacher,
      on_mount: [{AppWeb.TeacherAuth, :mount_current_teacher}] do
      live "/teachers/confirm/:token", TeacherConfirmationLive, :edit
      live "/teachers/confirm", TeacherConfirmationInstructionsLive, :new
    end
  end
end
