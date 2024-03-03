require "active_record"
require "rom-sql"
require "rom-repository"

module TestData
  PRIMARY_KEY = "wlz4KVKRRZklg7ErRc8thXNkl1aLJDut"
  KEY_DERIVATION_SALT = "e1l1PGsfsXtGJFpQnKCSF9eYZK4myMTu"

  def self.create_rom_container
    ::ROM.container(:sql, "sqlite://test/tmp/test.db") do |config|
      config.register_relation(TestData::ROM::SecretNotes)
    end
  end

  ActiveRecord::Encryption.configure(
    primary_key: TestData::PRIMARY_KEY,
    key_derivation_salt: TestData::KEY_DERIVATION_SALT
  )

  SHA256_KEY_GENERATOR =
    ::ActiveRecord::Encryption.with_encryption_context(key_generator: ::ActiveRecord::Encryption::KeyGenerator.new(hash_digest_class: OpenSSL::Digest::SHA256)) do
      ::ActiveRecord::Encryption::DerivedSecretKeyProvider.new(::ActiveRecord::Encryption.config.primary_key)
    end

  module ActiveRecord
    class SecretNote < ::ActiveRecord::Base
      encrypts :title, key_provider: SHA256_KEY_GENERATOR
      encrypts :content
    end
  end

  module ROM
    class SecretNotes < ::ROM::Relation[:sql]
      EncryptedString, EncryptedStringReader =
        RomEncryptedAttribute.define_encrypted_attribute_types(
          primary_key: PRIMARY_KEY,
          key_derivation_salt: KEY_DERIVATION_SALT
        )

      EncryptedStringSha256, EncryptedStringSha256Reader =
        RomEncryptedAttribute.define_encrypted_attribute_types(
          primary_key: PRIMARY_KEY,
          key_derivation_salt: KEY_DERIVATION_SALT,
          hash_digest_class: OpenSSL::Digest::SHA256
        )

      schema(:secret_notes, infer: true) do
        attribute :content, EncryptedString, read: EncryptedStringReader
        attribute :title, EncryptedStringSha256, read: EncryptedStringSha256Reader
      end
    end

    class SecretNoteRepository < ::ROM::Repository[:secret_notes]
      commands :create, update: :by_pk

      def find(id)
        secret_notes.by_pk(id).one!
      end
    end
  end
end
