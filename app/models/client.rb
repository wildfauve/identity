class Client

  include Wisper::Publisher
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  embeds_many :authorisations
  
  validates_presence_of :name, :redirect_uri
  
  field :name, type: String
  field :client_id, type: String
  field :secret, type: String
  field :redirect_uri, type: String
  
  #after_save :publish_save_event
  
  def create_me(params)
    self.name = params[:name]
    self.client_id = name.downcase.gsub(/ /, "_")
    self.secret = SecureRandom.urlsafe_base64(nil, false)
    self.redirect_uri = params[:redirect_uri]
    self.save
  end
  
  
  def update_me(params)
    self.name = params[:name]
    self.redirect_uri = params[:redirect_uri]
    determine_save_event_state()
  end
    
  def change_credentials
    self.secret = SecureRandom.urlsafe_base64(nil, false)
  end
    
  def create_auth_req(params: nil, user: nil)
    raise if self.redirect_uri != params[:redirect_uri]
    auth = Authorisation.create_it(params: params, user: user)
    self.authorisations << auth
    self.save
    auth
  end
  
  def last_auth_request(user: nil)
    auth = self.authorisations.last
    auth.add_user(user: user)
    self.save
    auth
  end
  
  
  def get_authorisation(code: nil)
    self.authorisations.where(auth_code: code).first
  end

  def get_access_authorisation(access_code: nil)
    self.authorisations.where(access_code: access_code).first
  end

  
  def provide_access(auth)
    auth.create_access_code
    save
    auth
  end
  
  def get_user(auth: nil)
    raise if !auth
    auth.user
  end
  
  private
    
    
  def determine_save_event_state
    if self.valid?
      self.save
      publish(:success_client_save_event, self)
    else
      publish(:failed_client_save_event, self)
    end
  end
      
  
end