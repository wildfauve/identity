class AuthorisationHandler
  
  include Wisper::Publisher
  
  attr_accessor :client, :auth
  
  # {"client_id"=>"client_service", "redirect_uri"=>"http://localhost:3000/identities/authorisation", "response_type"=>"code", "state"=>"signup"}  
  
  def process(params: nil, current_user: nil)
    @curr_user = current_user
    @client = find_client(client_id: params[:client_id])
    raise if !client
    @auth = client.create_auth_req(params: params, user: @curr_user)
    if @curr_user
      publish(:return_auth_event, self)
    else
      publish(:user_login_req_event, self)
    end
  end    
  
  def authorise_code_redirect
    q = {}
    q[:code] = @auth.auth_code
    q[:state] = @auth.state
    "#{@auth.redirect_url}?#{q.to_query}"
  end
  
  # {"grant_type"=>"authorization",
  # "code"=>"s0NQ3nDgcaz5fY2mL-u-ug",
  #  "redirect_uri"=>"http://localhost:3000/identities/authorisation",
  #  "action"=>"create",
  #  "controller"=>"token"}
  
  def provide_access_token(params: nil, client_credentials: nil)
    @client = valid_client(client_credentials: client_credentials)
    @auth = @client.get_authorisation(code: params[:code])
    publish(:failed_access_request, self) if !auth
    @client.provide_access(auth)
    publish(:valid_access_request, self)
  end
  
  def find_client(client_id: nil)
    cl = Client.where(client_id: client_id).first
    raise if !cl
    cl
  end
  
  def valid_client(client_credentials: nil)
    cl = find_client(client_id: client_credentials[:client_id])
    raise if cl.secret != client_credentials[:client_secret]
    cl
  end
  
end