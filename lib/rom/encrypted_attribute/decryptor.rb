# frozen_string_literal: true

require "base64"
require "json"
require_relative "payload"

module ROM
  module EncryptedAttribute
    class Decryptor
      def initialize(derivator:)
        @derivator = derivator
      end

      def decrypt(message)
        return nil if message.nil?

        payload = ROM::EncryptedAttribute::Payload.decode(message)

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
end
