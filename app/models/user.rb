class User
  
  #attr_accessible :name, :password, :email
  
  attr_accessor :password
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :name, :type => String 
  field :email, :type => String
  field :password_hash, type: String 
  field :password_salt, type: String
  field :pin, type: String
  
  embeds_many :metadata
  
  embeds_many :id_references
  
  before_save :encrypt
  
  def self.create_it(params)
    user = self.new.create_me(params[:user])
    user
  end
  
  def self.authenticate(name: nil, password: nil, pin: nil)
    if pin
      user = self.where(pin: pin).first
      valid = user if user
    else
      user = self.where(name: name).first
      valid = user if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
    end
    valid ? valid : nil
  end

#{"event":"kiwi_identity",
#  "ref":[{"link":"http://localhost:3021/api/v1/parties/545964134d6174bb8d050000","ref":"party"},
# {"ref":"sub","id":"545963db4d61745aead30000"}],
# "id_token":{"sub":"545963db4d61745aead30000"}}
  def self.id_reference(event)
    user = self.find(event["id_token"]["sub"])
    user.add_references(refs: event["ref"])
  end

  def create_me(params)
    self.name = params[:name]
    self.password = params[:password]
    self.email = params[:email]
    self.save
    self
  end
  
  def update_meta(meta: nil)
    meta.each do |name, value|
      mt = self.metadata.where(name: name).first
      if mt
        mt.update_it(name: name, value: value)
      else
        self.metadata << Metadatum.create_it(name: name, value: value)
      end
    end
    save
  end

  def update_it(params)
    self.attributes = (params[:user])
    if params[:employee].present?
      emp = Employee.find(params[:employee])
      self.employee = emp
    end    
    save
  end
  
  def encrypt
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)      
    end
  end
  
  def add_references(refs: nil)
    refs.each do |ref|
      if ref["ref"] != "sub"
        id_ref = self.id_references.where(ref: ref["ref"]).first
        if id_ref
          id_ref.update_it(ref: ref["ref"], link: ref["link"], id: ref["id"])
        else
          self.id_references << IdReference.create_it(ref: ref["ref"], link: ref["link"], id: ref["id"])
        end
      end
    end
    self.save
  end
  
  def reference_for(ref: nil)
    self.id_references.where(ref: ref).first
  end
  
end