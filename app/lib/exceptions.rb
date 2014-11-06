module Exceptions
  
  class FishError < StandardError 
    attr :errorcode, :model
    
    def intialize
      @errorcode = 1000
    end
  
  end
  
  class OauthError < FishError
    @@domain = "OAuth2"
    
    def domain
      @@domain
    end
    
  end
  
  class InvalidResponseCode < OauthError
    
    def initialize
      @errorcode = 1001
    end
    
    def message
      "The Response Code must be 'code'"
    end
  end

  class InvalidClientRedirect < OauthError
    def initialize
      @errorcode = 1001
    end
    
    def message
      "The Redirect URI does not match that registered"
    end
    
  end

  class ClientIdInvalid < OauthError
  end
  
  class AccessCodeInvalid <OauthError
  end
  
end