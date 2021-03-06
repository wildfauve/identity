class AuthoriseController < ApplicationController
  
  # {"client_id"=>"client_service", "redirect_uri"=>"http://localhost:3000/identities/authorisation", "response_type"=>"code", "scope"=>"signup"}  
  
  def index
    #raise if session[:client_id] && @current_user
    auth_req = AuthorisationHandler.new
    auth_req.subscribe(self)
    #auth_req.process(params: params, current_user: @current_user, in_progress_client: session[:client_id])
    auth_req.process(params: params, current_user: @current_user, in_progress_client: nil)    
  end
  
  def create
  end
  
  def return_auth_event(auth)
    session[:client_id] = nil
    redirect_to auth.authorise_code_redirect
  end
  
  def user_login_req_event(auth)
    session[:client_id] = auth.client.client_id
    session[:scope] = auth.scope
    redirect_to log_in_path(scope: auth.scope)
  end

  def user_signup_req_event(auth)
    session[:client_id] = auth.client.client_id
    redirect_to sign_up_path
  end
  
  
end