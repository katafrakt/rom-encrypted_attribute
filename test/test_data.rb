require "active_record"
require "rom-sql"
require "rom-repository"

module TestData
  PRIMARY_KEY = "wlz4KVKRRZklg7ErRc8thXNkl1aLJDut"
  DERIVATION_SALT = "e1l1PGsfsXtGJFpQnKCSF9eYZK4myMTu"

  def self.create_rom_container
    ::ROM.container(:sql, "sqlite://test/tmp/test.db") do |config|
      config.register_relation(TestData::ROM::SecretNotes)
    end
  end

  module ActiveRecord
    class SecretNote < ::ActiveRecord::Base
      encrypts :content
    end
  end

  module ROM
    class SecretNotes < ::ROM::Relation[:sql]
      EncryptedString, EncryptedStringReader =
        RomEncryptedAttribute.define_encrypted_attribute_types(
          primary_key: PRIMARY_KEY,
          derivation_salt: DERIVATION_SALT
        )

      schema(:secret_notes, infer: true) do
        attribute :content, EncryptedString, read: EncryptedStringReader
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
