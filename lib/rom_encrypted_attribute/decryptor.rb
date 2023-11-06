# frozen_string_literal: true

require "base64"
require "json"
require_relative "key_derivator"

module RomEncryptedAttribute
  class Decryptor
    def initialize(secret:, salt:)
      @derivator = KeyDerivator.new(secret: secret, salt: salt)
    end

    def decrypt(message)
      message = JSON.parse(message)
      data = Base64.strict_decode64(message["p"])
      iv = Base64.strict_decode64(message["h"]["iv"])
      auth_tag = Base64.strict_decode64(message["h"]["at"])

      cipher = OpenSSL::Cipher.new("aes-256-gcm")
      key = @derivator.derive(cipher.key_len)

      cipher.decrypt
      cipher.padding = 0
      cipher.key = key
      cipher.iv = iv
      cipher.auth_tag = auth_tag
      cipher.auth_data = ""
      cipher.update(data) + cipher.final
    rescue JSON::ParserError
      # we need to unconditionally support of reading unencrypted data due to a bug in rom-sql
      # https://github.com/rom-rb/rom-sql/issues/423
      message
    end
  end
end
