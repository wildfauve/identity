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
    user_mgr = UserManager.new
    user_mgr.subscribe(self)
    user_mgr.authenticate(cred: params, client_id: session[:client_id])
  end
  
  def destroy
    auth = AuthorisationHandler.new
    auth.subscribe(self)
    auth.logout(id_token: params[:id_token_hint], redirect_uri: params[:post_logout_redirect_uri], current_user: @current_user, local: params[:local])
  end
  
  def continue_oauth_auth_req_event(user, client_id)
    session[:user_id] = user.id
    session[:client_id] = client_id
    redirect_to authorise_index_path
  end
  
  def successful_internal_login_event(user)
    session[:user_id] = user.id
    redirect_to sessions_path
  end
  
  def invalid_login_event(user)
    flash.now.alert = "Invalid Login"
    redirect_to new_sessions_path
  end
  
  def successful_logout_event(redirect_uri)
    session[:user_id] = nil
    redirect_to redirect_uri
  end
  
end