class Timestamp
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :timestamp, type: Time
  field :state, type: Symbol
  field :name, type: Symbol

  embedded_in :order
  
  def self.new_state(state: nil, name: nil)
    time = self.new
    time.timestamp = Time.now
    time.state = state
    time.name = name
    time
  end
  
end