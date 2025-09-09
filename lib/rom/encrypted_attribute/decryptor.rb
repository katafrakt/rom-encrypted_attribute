# frozen_string_literal: true

require "base64"
require "json"
require_relative "payload"

module ROM
  module EncryptedAttribute
    class Decryptor
      UnencryptedDataNotAllowed = Class.new(RuntimeError)

      def initialize(derivator:, support_unencrypted_data: false)
        @derivator = derivator
        @support_unencrypted_data = support_unencrypted_data
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
        if @support_unencrypted_data
          message
        else
          raise UnencryptedDataNotAllowed
        end
      end
    end
  end
end
