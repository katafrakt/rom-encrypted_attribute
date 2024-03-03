# frozen_string_literal: true

require_relative "rom_encrypted_attribute/key_derivator"
require_relative "rom_encrypted_attribute/decryptor"
require_relative "rom_encrypted_attribute/encryptor"
require_relative "rom_encrypted_attribute/version"

require "dry/types"

module RomEncryptedAttribute
  def self.define_encrypted_attribute_types(primary_key:, key_derivation_salt:, hash_digest_class: OpenSSL::Digest::SHA1)
    key_derivator = KeyDerivator.new(salt: key_derivation_salt, secret: primary_key, hash_digest_class: hash_digest_class)

    reader_type = Dry.Types.Constructor(String) do |value|
      RomEncryptedAttribute::Decryptor.new(derivator: key_derivator).decrypt(value)
    end

    writer_type = Dry.Types.Constructor(String) do |value|
      RomEncryptedAttribute::Encryptor.new(derivator: key_derivator).encrypt(value)
    end

    [writer_type, reader_type]
  end
end
