# frozen_string_literal: true

require "openssl"

module ROM
  module EncryptedAttribute
    class KeyDerivator
      DEFAULT_DIGEST_CLASS = OpenSSL::Digest::SHA1
      ITERATIONS = 2**16

      def initialize(secret:, salt:, hash_digest_class: DEFAULT_DIGEST_CLASS)
        @secret = secret
        @salt = salt
        @hash_digest_class = hash_digest_class
      end

      def derive(size)
        OpenSSL::PKCS5.pbkdf2_hmac(@secret, @salt, ITERATIONS, size, @hash_digest_class.new)
      end
    end
  end
end
