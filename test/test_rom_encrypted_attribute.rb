# frozen_string_literal: true

require "test_helper"

class TestEncryptedAttribute < Minitest::Test
  def setup
    ROM::SQL::Patch432.install!
    rom = TestData.create_rom_container
    @db = rom.gateways[:default]
    @repo = TestData::ROM::SecretNoteRepository.new(rom)
  end

  def teardown
    ROM::SQL::Patch432.uninstall!
  end

  def test_support_nulls
    note = @repo.create(title: "test")
    read_note = @repo.find(note.id)
    assert_nil read_note.content
  end

  def test_can_read_what_it_wrote
    note = @repo.create(title: "test", content: "test content")
    read_note = @repo.find(note.id)
    assert_equal "test content", read_note.content
  end

  def test_can_read_what_it_wrote_using_custom_hash_digest
    note = @repo.create(title: "test", content: "test content")
    read_note = @repo.find(note.id)
    assert_equal "test", read_note.title
  end

  def test_can_update_and_read_it
    note = @repo.create(title: "test", content: "test content")
    @repo.update(note.id, content: "better one")
    read_note = @repo.find(note.id)
    assert_equal "better one", read_note.content
  end

  def test_update_of_non_encrypted_field_does_not_break_anything
    note = @repo.create(title: "test", content: "test content")
    @repo.update(note.id, title: "test v2")
    read_note = @repo.find(note.id)
    assert_equal "test content", read_note.content
  end

  def test_does_not_write_unencrypted_message
    note = @repo.create(title: "test", content: "content")
    raw = @db[:secret_notes].where(id: note.id).first
    refute_includes raw[:content], "content"
    refute_includes raw[:title], "test"
  end

  def test_raise_on_reading_unencrypted_value
    note_id = @db[:secret_notes].insert(title: "plain", content: "text", comment: "test comment")
    assert_raises(ROM::EncryptedAttribute::Decryptor::UnencryptedDataNotAllowed) {
      @repo.find(note_id)
    }
  end

  def test_read_unencrypted_value_when_allowed
    note = @repo.create(title: "plain", content: "text")
    @db[:secret_notes].where(id: note.id).update(maybe_encrypted: "plain little text")
    note = @repo.find(note.id)
    assert_equal "plain little text", note.maybe_encrypted
  end
end
