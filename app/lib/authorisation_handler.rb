class AuthorisationHandler
  
  include Wisper::Publisher
  
  include UrlHelpers
  
  attr_accessor :client, :auth, :scope
    
  def process(params: nil, current_user: nil, in_progress_client: nil)
    @curr_user = current_user
    #@in_progress_client = in_progress_client
    @req_client_id = params[:client_id]
    @scope = params[:scope]
    raise Exceptions::ClientIdInvalid if no_client()
    #@client = find_client(client_id: determine_client_id_to_use())
    @client = find_client(client_id: @req_client_id)
    if @scope == "signup"
      process_signup()
    else
      process_login(params)
    end
  end   
  
  def determine_client_id_to_use
    raise
    @req_client_id.nil? ? @in_progress_client : @req_client_id
  end 
  
  def in_flow_progress
    raise
    @in_progress_client ? true : false
    #(params[:client_id].nil? && client_id) || (params[:client_id] && client_id) # if we have an attempt that incorporated a login prior to replying with an auth code
  end
  
  def no_client
     @req_client_id.nil? ? true : false
    #@in_progress_client.nil? && @req_client_id.nil? ? true : false
  end
  
  def process_login(params)
    #if in_flow_progress()
      #@auth = @client.last_auth_request(user: @curr_user)
      #else 
      raise Exceptions::InvalidResponseCode if params[:response_type] != "code"      
      @auth = @client.get_auth_req(params: params, user: @curr_user) if @curr_user
      #end
    if @curr_user
      publish(:return_auth_event, self)
    else
      if ["basic_profile", "atm"].include? @scope
        publish(:user_login_req_event, self)
      else
        raise
      end
    end
  end
  
  def process_signup
    publish(:user_signup_req_event, self)
  end
  
  def authorise_code_redirect
    q = {}
    q[:code] = @auth.auth_code
    q[:state] = @auth.state
    "#{@auth.redirect_url}?#{q.to_query}"
  end
  
  # {"grant_type"=>"authorization",
  # "code"=>"s0NQ3nDgcaz5fY2mL-u-ug",
  #  "redirect_uri"=>"http://localhost:3000/identities/authorisation"
  
  def provide_access_token(params: nil, client_credentials: nil)
    @client = validate_client_credentials(client_credentials: client_credentials)
    raise Exceptions::InvalidClientRedirect if params[:redirect_uri] != @client.redirect_uri
    @auth = @client.get_authorisation(code: params[:code])
    publish(:failed_access_request, self) if !@auth
    @client.provide_access(auth)
    publish(:valid_access_request, self)
  end

  def update_meta(params: nil, access_code: nil)
    client_auth = get_client_by_access_code(access_code: access_code)
    publish(:failed_meta_request, self) if !client_auth
    @user = client_auth[:auth].user.update_meta(meta: params)
    publish(:successful_meta_request, self)
  end
  
  def find_client(client_id: nil)
    cl = Client.where(client_id: client_id).first
    raise Exceptions::ClientIdInvalid if !cl
    cl
  end
  
  def get_client_by_access_code(access_code: nil)
    # remove the Bearer part of the access code
    raise Exceptions::AccessCodeInvalid if !access_code
    bearer = access_code.split(/ /)
    raise if bearer.size != 2 || bearer[0] != "Bearer"
    code = bearer[1]
    client = Client.where('authorisations.access_code' => code).first
    raise if !client
    auth = client.get_access_authorisation(access_code: code)
    raise if !auth
    {client: client, auth: auth }
  end
  
  def validate_client_credentials(client_credentials: nil)
    cl = find_client(client_id: client_credentials[:client_id])
    raise Exceptions::ClientCredentialsInvalid if cl.nil? || cl.secret != client_credentials[:client_secret]
    cl
  end
  
  def logout(id_token: nil, redirect_uri: nil, current_user: nil, local: nil)
    if local == "true"
      local_logout(current_user: current_user) 
    else
      raise if !id_token
      jwt = JWT.decode(id_token, Identity::Application.config.id_token_secret)
      user = User.find(jwt[0]["sub"])
      raise if user != current_user
      client = Client.where(client_id: jwt[0]["aud"]).first
      raise if redirect_uri != client.post_logout_redirect_uri
      publish(:successful_logout_event, redirect_uri)
    end
  end
  
  def local_logout(current_user: nil)
    publish(:successful_logout_event, url_helpers.sessions_path)
  end
  
  def invalid_oauth_login_error(client_id: nil)
    client = Client.where(client_id: client_id).first
    q = {}
    q[:error] = "invalid_login"
    "#{client.redirect_uri}?#{q.to_query}" 
  end
  
end