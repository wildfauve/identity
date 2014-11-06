class IdReference
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :ref, :type => String 
  field :link, :type => String
  field :identifier, :type => String
  
  embedded_in :user
  
  def self.create_it(ref: nil, link: nil, id: nil)
    id = self.new
    id.update_it(ref: ref, link: link, id: id)
    id
  end
  
  def update_it(ref: nil, link: nil, id: nil)
    self.ref = ref
    self.link = link
    self.identifier = id
    self 
  end
    
end
