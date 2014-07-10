class TokenController < ApplicationController

  protect_from_forgery except: :create
  
  # {"grant_type"=>"authorization",
  # "code"=>"s0NQ3nDgcaz5fY2mL-u-ug",
  #  "redirect_uri"=>"http://localhost:3000/identities/authorisation",
  #  "action"=>"create",
  #  "controller"=>"token"}
  
  def create
    authenticate_with_http_basic do |u, p|
      access_req = AuthorisationHandler.new
      access_req.subscribe(self)
      access_req.provide_access_token(params: params, client_credentials: {client_id: u, client_secret: p})
    end
  end
  
  def valid_access_request(auth)
    @auth = auth
    params[:format] = :json 
    render 'access_code'
  end
  
end