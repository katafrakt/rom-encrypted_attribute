# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rom/encrypted_attribute"

require "minitest/autorun"
require_relative "test_data"
require "active_record"
require "rom/encrypted_attribute/rom_sql_patch"

FileUtils.rm("test/tmp/test.db") if File.exist?("test/tmp/test.db")
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "test/tmp/test.db")

class CreateSecretNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :secret_notes do |t|
      t.string :title
      t.string :content
      t.string :comment
      t.string :maybe_encrypted
    end
  end
end

CreateSecretNotes.migrate :up

ROM::EncryptedAttribute.configure do |config|
  config.primary_key = TestData::PRIMARY_KEY
  config.key_derivation_salt = TestData::KEY_DERIVATION_SALT
end
