class SessionsController < ApplicationController  
  def new
  end

  def create
    admin = Admin.first
    if admin.authenticate(params[:password])
      session[:admin_id] = admin.id
      flash[:notice] = "Welcome, logged in"
      redirect_to root_path
    else
      flash[:error] = "something wrong"
      redirect_to login_path
    end
  end
  
  def destroy
    session[:admin_id] = nil
    flash[:notice] = "logged out"
    redirect_to login_path
  end
end
