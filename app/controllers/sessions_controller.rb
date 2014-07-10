class SessionsController < ApplicationController
  
  def index
  end
  
  def new 
    @session = User.new 
    respond_to do |format| 
      format.html 
    end 
  end
  
  def create
    user = User.authenticate(name: params[:user][:name], password: params[:user][:password])
    respond_to do |format|
      if user
        session[:user_id] = user.id
        format.html { redirect_to sessions_path }
      else
        flash.now.alert = "Invalid Login"
        format.html { render action: "new" }
      end
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out"
  end
  
end