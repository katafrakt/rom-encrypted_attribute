# frozen_string_literal: true

require_relative "rom_encrypted_attribute/decryptor"
require_relative "rom_encrypted_attribute/encryptor"
require_relative "rom_encrypted_attribute/version"

require "dry/types"

module RomEncryptedAttribute
  def self.define_encrypted_attribute_types(primary_key:, key_derivation_salt:)
    reader_type = Dry.Types.Constructor(String) do |value|
      RomEncryptedAttribute::Decryptor.new(secret: primary_key, salt: key_derivation_salt).decrypt(value)
    end

    writer_type = Dry.Types.Constructor(String) do |value|
      RomEncryptedAttribute::Encryptor.new(secret: primary_key, salt: key_derivation_salt).encrypt(value)
    end

    [writer_type, reader_type]
  end
end
