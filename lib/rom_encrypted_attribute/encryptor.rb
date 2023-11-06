# frozen_string_literal: true

require "base64"
require "json"
require "openssl"
require_relative "key_derivator"

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
      serialize(encrypted, cipher: cipher, iv: iv)
    end

    private

    def serialize(encrypted, iv:, cipher:)
      payload =
        {
          "p" => Base64.strict_encode64(encrypted),
          "h" => {
            "iv" => Base64.strict_encode64(iv),
            "at" => Base64.strict_encode64(cipher.auth_tag)
          }
        }

      JSON.dump(payload)
    end
  end
end
