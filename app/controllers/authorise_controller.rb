class AuthoriseController < ApplicationController
  
  def index
    #raise if session[:client_id] && @current_user
    auth_req = AuthorisationHandler.new
    auth_req.subscribe(self)
    auth_req.process(params: params, current_user: @current_user, client_id: session[:client_id])
  end
  
  def create
  end
  
  def return_auth_event(auth)
    session[:client_id] = nil
    redirect_to auth.authorise_code_redirect
  end
  
  def user_login_req_event(auth)
    session[:client_id] = auth.client.client_id
    redirect_to log_in_path
  end
  
  
end