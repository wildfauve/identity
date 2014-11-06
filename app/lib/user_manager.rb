class UserManager
  
  attr_accessor :client, :user
  
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
  
  def create_user(user: nil, client_id: nil)
    @user = User.create_it(user)
    if client_id
      @client = Client.where(client_id: client_id ).first
      publish(:continue_oauth_auth_req_event, self)
    else
      publish(:successful_internal_login_event, user)
    end
  end

  
end