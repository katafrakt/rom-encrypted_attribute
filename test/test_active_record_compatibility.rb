require "test_helper"

class TestActiveRecrodCompatibility < Minitest::Test
  def setup
    @rom = TestData.create_rom_container
    @repo = TestData::ROM::SecretNoteRepository.new(@rom)
  end

  def test_derive_the_same_key
    active_record_derived_key = ActiveRecord::Encryption.key_generator.derive_key_from(ActiveRecord::Encryption.config.primary_key)

    cipher = OpenSSL::Cipher.new("aes-256-gcm")
    rom_derived_key = ROM::EncryptedAttribute::KeyDerivator.new(
      secret: TestData::PRIMARY_KEY,
      salt: TestData::KEY_DERIVATION_SALT
    ).derive(cipher.key_len)
    assert_equal active_record_derived_key, rom_derived_key
  end

  def test_record_created_in_active_record_can_be_read_from_rom
    note = TestData::ActiveRecord::SecretNote.create!(title: "Note from AR", content: "I'm top secret", comment: "Created with ActiveRecord")
    read_note = @repo.find(note.id)
    assert_equal note.title, read_note.title
    assert_equal note.content, read_note.content
    assert_equal note.comment, read_note.comment
  end

  def test_record_create_in_rom_can_be_read_from_active_record
    note = @repo.create(title: "Note from ROM", content: "You can't read me, even if you steal the database", comment: "plain text")
    read_note = TestData::ActiveRecord::SecretNote.find(note.id)
    assert_equal note.title, read_note.title
    assert_equal note.content, read_note.content
    assert_equal note.comment, read_note.comment
  end
end
