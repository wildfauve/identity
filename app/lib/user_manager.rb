class UserManager
  
  include Wisper::Publisher
  
  def authenticate(cred: nil, client_id: nil)
    user = User.authenticate(name: cred[:user][:name], password: cred[:user][:password])
    if user
      if client_id
        publish(:continue_oauth_auth_req_event, user, client_id)
      else
        publish(:successful_internal_login_event, user)
      end
    else
      publish(:invalid_login_event, user)
    end
  end

  
end