# frozen_string_literal: true

require "test_helper"

class TestRomEncryptedAttribute < Minitest::Test
  def setup
    rom = TestData.create_rom_container
    @db = rom.gateways[:default]
    @repo = TestData::ROM::SecretNoteRepository.new(rom)
  end

  def test_can_read_what_it_wrote
    note = @repo.create(title: "test", content: "test content")
    read_note = @repo.find(note.id)
    assert_equal "test content", read_note.content
  end

  def test_can_read_what_it_wrote_using_custom_key_derivation
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

  # NOTE: this should be configurable, but due to a bug in rom-sql, it needs to be
  # enabled by default. Expect a breaking change in the future.
  def test_can_read_unencrypted_value
    note_id = @db[:secret_notes].insert(title: "plain", content: "text", comment: "test comment")
    read_note = @repo.find(note_id)
    assert_equal "test comment", read_note.comment
  end
end
