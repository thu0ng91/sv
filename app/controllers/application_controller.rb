class ApplicationController < ActionController::Base
  protect_from_forgery


  helper_method :current_admin, :logged_in?
  
  def current_admin
    @admin ||= Admin.find(session[:admin_id]) if session[:admin_id]
  end

  def logged_in?
    !!current_admin
  end

  def access_denied
    flash[:error] = "You can't do that"
    redirect_to login_path
  end

  def require_admin
    access_denied unless current_admin
  end
end
