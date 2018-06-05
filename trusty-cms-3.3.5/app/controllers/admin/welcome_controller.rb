class Admin::WelcomeController < ApplicationController
  no_login_required
  before_action :never_cache
  skip_before_action :verify_authenticity_token

  def index
    redirect_to admin_pages_path
  end

  def login
    if request.post?
      @username_or_email = params[:username_or_email]
      password = params[:password]
      announce_invalid_user unless self.current_user = User.authenticate(@username_or_email, password)
    end
    if current_user
      if params[:remember_me]
        current_user.remember_me
        set_session_cookie
      end
      redirect_to(session[:return_to] || welcome_path)
      session[:return_to] = nil
    end
  end

  def logout
    request.cookies[:session_token] = { :expires => 1.day.ago.utc }
    self.current_user.forget_me if self.current_user
    self.current_user = nil
    announce_logged_out
    redirect_to login_path
  end

  private

    def never_cache
      expires_now
    end

    def announce_logged_out
      flash[:notice] = t('welcome_controller.logged_out')
    end

    def announce_invalid_user
      flash.now[:error] = t('welcome_controller.invalid_user')
    end

end
