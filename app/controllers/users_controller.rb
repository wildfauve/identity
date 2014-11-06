class UsersController < ApplicationController
  
  def index
  end
  
  def new 
    @user = User.new 
  end
  
  def create
    user_mgr = UserManager.new
    user_mgr.subscribe(self)
    user_mgr.create_user(user: params, client_id: session[:client_id])
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])    
    @user.update_it(params)
  end
  
  def userinfo
    #authenticate_with_http_basic do |u, p|
    #client = AuthorisationHandler.new.valid_client(client_credentials: {client_id: u, client_secret: p})
    client_auth = AuthorisationHandler.new.get_client_by_access_code(access_code: request.headers['Authorization'])
    @user = client_auth[:client].get_user(auth: client_auth[:auth])
    render 'me'
  end
  
  def continue_oauth_auth_req_event(usermgr)
    # {"client_id"=>"client_service", "redirect_uri"=>"http://localhost:3000/identities/authorisation", "response_type"=>"code", "scope"=>"signup"}
    session[:client_id] = nil
    redirect_to authorise_index_path(client_id: usermgr.client.client_id, response_type: "code", scope: "basic_profile",
                                     redirect_uri: usermgr.client.redirect_uri)
  end
  
end