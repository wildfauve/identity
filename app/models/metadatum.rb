class Metadatum
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :name, :type => String 
  field :value, :type => String
  field :multi_value, type: Array
  
  embedded_in :user
  
  def self.create_it(name: nil, value: nil)
    mt = self.new
    mt.update_it(name: name, value: value)
    mt
  end
  
  def update_it(name: nil, value: nil)
    self.name = name
    if value.is_a? Array
      self.multi_value = value
    else
      self.value = value
    end
    self 
  end
  
  def typed_value
    self.value ? value : multi_value 
  end
  
end
