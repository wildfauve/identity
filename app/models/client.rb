class Client

  include Wisper::Publisher
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  embeds_many :authorisations
  
  field :name, type: String
  field :client_id, type: String
  field :secret, type: String
  
  after_save :publish_save_event
  
  def create_me(params)
    self.name = params[:name]
    self.client_id = name.downcase.gsub(/ /, "_")
    self.secret = BCrypt::Engine.generate_salt
    self.save!
    self
  end
  
  
  def update_it(params)
    self.name = params[:name]
    self.save!
    self 
  end
    
    
  def create_auth_req(params: nil, user: nil)
    auth = Authorisation.create_it(params: params, user: user)
    self.authorisations << auth
    self.save
    auth
  end
  
  
  def get_authorisation(code: nil)
    self.authorisations.where(auth_code: code).first
  end
  
  def provide_access(auth)
    auth.create_access_code
    save
    auth
  end
  
  def get_user(access_code: nil)
    auth = self.authorisations.where(access_code: access_code).first
    raise if !auth
    auth.user
  end
  
  private
    
  
  def publish_save_event
    publish(:success_client_save_event, self)
  end
    
  
end