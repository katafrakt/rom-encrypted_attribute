# frozen_string_literal: true

require_relative "encrypted_attribute/key_derivator"
require_relative "encrypted_attribute/decryptor"
require_relative "encrypted_attribute/encryptor"
require_relative "encrypted_attribute/version"
require_relative "plugins/schema/encrypted_attributes"

require "dry/types"

module ROM
  module EncryptedAttribute
    extend Dry::Configurable

    setting :primary_key
    setting :key_derivation_salt
    setting :hash_digest_class, default: OpenSSL::Digest::SHA1

    def self.define_encrypted_attribute_types(primary_key:, key_derivation_salt:, hash_digest_class: OpenSSL::Digest::SHA1)
      key_derivator = KeyDerivator.new(salt: key_derivation_salt, secret: primary_key,
        hash_digest_class: hash_digest_class)

      reader_type = Dry.Types.Constructor(String) do |value|
        ROM::EncryptedAttribute::Decryptor.new(derivator: key_derivator).decrypt(value)
      end

      writer_type = Dry.Types.Constructor(String) do |value|
        ROM::EncryptedAttribute::Encryptor.new(derivator: key_derivator).encrypt(value)
      end

      [writer_type, reader_type]
    end
  end
end
