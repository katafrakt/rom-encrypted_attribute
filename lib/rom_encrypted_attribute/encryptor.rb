# frozen_string_literal: true

require "base64"
require "json"
require "openssl"
require_relative "key_derivator"
require_relative "payload"

module RomEncryptedAttribute
  class Encryptor
    def initialize(secret:, salt:)
      @derivator = KeyDerivator.new(secret: secret, salt: salt)
    end

    def encrypt(message)
      cipher = OpenSSL::Cipher.new("aes-256-gcm")
      key = @derivator.derive(cipher.key_len)
      iv = cipher.random_iv

      cipher.encrypt
      cipher.key = key
      cipher.iv = iv
      encrypted = cipher.update(message) + cipher.final
      Payload.new(message: encrypted, initialization_vector: iv, auth_tag: cipher.auth_tag).encode
    end
  end
end
