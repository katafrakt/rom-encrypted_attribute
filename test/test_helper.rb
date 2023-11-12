# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rom_encrypted_attribute"

require "minitest/autorun"
require_relative "test_data"
require "active_record"

FileUtils.rm("test/tmp/test.db") if File.exist?("test/tmp/test.db")
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "test/tmp/test.db")

ActiveRecord::Encryption.configure(
  primary_key: TestData::PRIMARY_KEY,
  key_derivation_salt: TestData::KEY_DERIVATION_SALT,
  hash_digest_class: OpenSSL::Digest::SHA256
)

class CreateSecretNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :secret_notes do |t|
      t.string :title
      t.string :content
    end
  end
end

CreateSecretNotes.migrate :up
