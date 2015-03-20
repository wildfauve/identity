require 'openssl' 

module PKI

  class PKI
  
    attr_accessor :key, :encrypted_msg
  
    def initialize
      @key_pair_location = "#{Rails.root.join('lib', 'keys')}"
      self.load_keys if !@key
    end
  
    def load_keys
      if File.exist?("#{@key_pair_location}/private_key.pem")
        @key = OpenSSL::PKey::RSA.new File.read "#{@key_pair_location}/private_key.pem"
      elsif File.exist?("#{@key_pair_location}/public_key.pem")
        @key = OpenSSL::PKey::RSA.new File.read "#{@key_pair_location}/public_key.pem"
      else
        raise
        #self.generate_key_pair
      end
    end
  
    def generate_key_pair(key_length: 2048)
      @key_pair = OpenSSL::PKey::RSA.new key_length
    end
  
    def write_key
      open "#{@key_pair_location}private_key.pem", 'w' do |io| io.write @key_pair.to_pem end
      open "#{@key_pair_location}public_key.pem", 'w' do |io| io.write @key_pair.public_key.to_pem end
    end
  
  	def encrypt_RSA(message: nil)
  	  @encrypted_msg = @key_pair.public_encrypt(message, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
    end
  
    def decrypt_RSA
    	@message = @key_pair.private_decrypt(@encrypted_msg, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
    end
  
  end

end
