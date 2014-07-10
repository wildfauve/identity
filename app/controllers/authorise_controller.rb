class AuthoriseController < ApplicationController
  
  def index
    auth_req = AuthorisationHandler.new
    auth_req.subscribe(self)
    auth_req.process(params: params, current_user: @current_user)
    
  end
  
  def create
  end
  
  def return_auth_event(auth)
    redirect_to auth.authorise_code_redirect
  end
  
  
  
end