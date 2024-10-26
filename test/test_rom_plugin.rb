# frozen_string_literal: true

require "test_helper"

class TestRomPlugin < Minitest::Test
  class SecretNotes < ::ROM::Relation[:sql]
    schema(:secret_notes, infer: true) do
      use :encrypted_attributes
      encrypt :content
      encrypt :title, hash_digest_class: OpenSSL::Digest::SHA256
    end
  end

  class SecretNoteRepository < ::ROM::Repository[:secret_notes]
    commands :create, update: :by_pk

    def find(id)
      secret_notes.by_pk(id).one!
    end
  end

  def setup
    rom =
      ::ROM.container(:sql, "sqlite://test/tmp/test.db") do |config|
        config.register_relation(SecretNotes)
      end
    @db = rom.gateways[:default]
    @repo = SecretNoteRepository.new(rom)
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

  def test_can_read_unencrypted_value
    note_id = @db[:secret_notes].insert(title: "plain", content: "text", comment: "test comment")
    read_note = @repo.find(note_id)
    assert_equal "test comment", read_note.comment
  end
end
