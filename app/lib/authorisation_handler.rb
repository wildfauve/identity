class AuthorisationHandler
  
  include Wisper::Publisher
  
  attr_accessor :client, :auth
  
  # {"client_id"=>"client_service", "redirect_uri"=>"http://localhost:3000/identities/authorisation", "response_type"=>"code", "state"=>"signup"}  
  
  def process(params: nil, current_user: nil, client_id: nil)
    @curr_user = current_user
    params[:client_id].nil? ? cl_id = client_id : cl_id = params[:client_id]
    @client = find_client(client_id: cl_id)
    if params[:client_id].nil? && client_id # if we have an attempt that incorporated a login prior to replying with an auth code
      @auth = @client.last_auth_request(user: @curr_user)
    elsif params[:client_id] && client_id.nil? # if the user is already logged in
      @auth = @client.create_auth_req(params: params, user: @curr_user)
    else
      raise
    end
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
  
  def get_client_by_access_code(access_code: nil)
    # remove the Bearer part of the access code
    raise if !access_code
    bearer = access_code.split(/ /)
    raise if bearer.size != 2 || bearer[0] != "Bearer"
    code = bearer[1]
    client = Client.where('authorisations.access_code' => code).first
    raise if !client
    auth = client.get_access_authorisation(access_code: code)
    raise if !auth
    {client: client, auth: auth }
  end
  
  def valid_client(client_credentials: nil)
    cl = find_client(client_id: client_credentials[:client_id])
    raise if cl.secret != client_credentials[:client_secret]
    cl
  end
  
end