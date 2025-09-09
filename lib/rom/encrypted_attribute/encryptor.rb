# frozen_string_literal: true

require "base64"
require "json"
require "openssl"
require_relative "payload"

module ROM
  module EncryptedAttribute
    class Encryptor
      def initialize(derivator:)
        @derivator = derivator
      end

      def encrypt(message)
        return nil if message.nil?

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
end
