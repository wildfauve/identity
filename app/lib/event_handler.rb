class EventHandler
  
  # In order to publish message we need a exchange name.
    # Note that RabbitMQ does not care about the payload -
    # we will be using JSON-encoded strings
    def self.publish(exchange: nil, message: {})
      # grab the fanout exchange
      x = channel.fanout("kiwi.#{exchange}")
      # and simply publish message
      x.publish(message.to_json)
    end

    def self.channel
      @channel ||= connection.create_channel
    end

    # We are using default settings here
    # The `Bunny.new(...)` is a place to
    # put any specific RabbitMQ settings
    # like host or port
    def self.connection
      @connection ||= Bunny.new.tap do |c|
        c.start
      end
    end
  
    # This is not an event at the mo; created through an API call in Kiwi
  #def self.customer_create_event(customer)
  #  self.publish(exchange: "events", message: customer.create_event)
  #end
  
  def self.return_auth_event(auth)
    #self.publish(exchange: "events", message: auth.auth.auth_event)
  end
  
end