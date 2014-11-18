class SessionsController < ApplicationController
  
  def index
  end
  
  def new 
    @session = User.new 
    @scope = params[:scope]
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
  
  # Recreate the Oauth Request
  # {"client_id"=>"client_service", "redirect_uri"=>"http://localhost:3000/identities/authorisation", "response_type"=>"code", "scope"=>"signup"}  
  
  def continue_oauth_auth_req_event(user, client_id)
    session[:user_id] = user.id
    client = Client.where(client_id: client_id).first
    redirect_to authorise_index_path(client_id: client_id, response_type: :code, scope: session[:scope], redirect_uri: client.redirect_uri)
  end
  
  def successful_internal_login_event(user)
    session[:user_id] = user.id
    redirect_to sessions_path
  end
  
  def invalid_oauth_login_event(user, client_id)
    redirect_to AuthorisationHandler.new.invalid_oauth_login_error(client_id: client_id)
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