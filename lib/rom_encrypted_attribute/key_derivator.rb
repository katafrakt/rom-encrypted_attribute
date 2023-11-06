# frozen_string_literal: true

require "openssl"

module RomEncryptedAttribute
  class KeyDerivator
    DIGEST_CLASS = OpenSSL::Digest::SHA256
    ITERATIONS = 2**16

    def initialize(secret:, salt:)
      @secret = secret
      @salt = salt
    end

    def derive(size)
      OpenSSL::PKCS5.pbkdf2_hmac(@secret, @salt, ITERATIONS, size, DIGEST_CLASS.new)
    end
  end
end
