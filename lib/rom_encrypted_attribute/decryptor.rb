# frozen_string_literal: true

require "base64"
require "json"
require_relative "key_derivator"
require_relative "payload"

module RomEncryptedAttribute
  class Decryptor
    def initialize(secret:, salt:)
      @derivator = KeyDerivator.new(secret: secret, salt: salt)
    end

    def decrypt(message)
      payload = RomEncryptedAttribute::Payload.decode(message)

      cipher = OpenSSL::Cipher.new("aes-256-gcm")
      key = @derivator.derive(cipher.key_len)

      cipher.decrypt
      cipher.padding = 0
      cipher.key = key
      cipher.iv = payload.initialization_vector
      cipher.auth_tag = payload.auth_tag
      cipher.auth_data = ""
      cipher.update(payload.message) + cipher.final
    rescue JSON::ParserError
      # we need to unconditionally support of reading unencrypted data due to a bug in rom-sql
      # https://github.com/rom-rb/rom-sql/issues/423
      message
    end
  end
end
