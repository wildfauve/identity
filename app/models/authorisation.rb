class Authorisation
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :redirect_url, type: String
  field :auth_code, type: String
  field :access_code, type: String
  field :state, type: String
  field :user_id, type: BSON::ObjectId
  field :expires_in, type: Time
  field :time_created, type: Time
  
  
  embedded_in :client
  
  def self.create_it(params: nil, user: nil)
    auth = self.new.create_me(params: params, user: user)
    auth
  end
  
  def create_me(params: nil, user: nil)
    self.redirect_url = params[:redirect_uri]
    self.auth_code = SecureRandom.urlsafe_base64(nil, false)
    self.state = params[:state]
    self.user_id = user.id if user
    self
  end
  
  def create_access_token
    self.access_code = SecureRandom.urlsafe_base64(nil, false)
    self.time_created = Time.now
    self.expires_in = Time.now + 1.hour
  end
  
  def add_user(user: nil) 
    self.user_id = user.id
    self
  end
  
  def expiry_duration
    self.expires_in - self.time_created
  end
    
  def user
    @user ||= User.find(self.user_id)
  end
  
  def id_token
    keys = PKI::PKI.new
    claims = {
            iss: "http://id.kiwibank.io",
            sub: self.user.id.to_s,
            aud: client.client_id,
            sub: client.client_id,
            exp: self.expires_in.to_i,
            email: self.user.email,
            mail_verified: false,
            preferred_username: self.user.name
          }
    claims[:reference_claims] = self.user.id_references.collect {|id| {ref: id.ref, link: id.link}}
    jwt = JSON::JWT.new(claims)
    jws = jwt.sign(keys.key, :RS512)
    jws.to_s
  end
  
  def auth_event
    {
      event: "authorisation_event",
      status: :success,
      timestamps: {
        expires_time: self.expires_in,
        create_time: self.time_created
      },
      client: {
        client_id: self.client.client_id,
        client_name: self.client.name
      },
      user: {
        name: self.user.name
      },
      party: {
        _links: {
          self: {
            href: self.user.reference_for(ref: :party).link
          }
        }
      }
    }
  end
  
end