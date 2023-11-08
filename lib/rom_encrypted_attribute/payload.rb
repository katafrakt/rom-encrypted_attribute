# frozen_string_literal: true

require "dry/types"
require "dry/struct"
require "base64"

class RomEncryptedAttribute::Payload < Dry::Struct
  class Types
    include Dry.Types()
  end

  attribute :message, Types::Strict::String
  attribute :initialization_vector, Types::Strict::String
  attribute :auth_tag, Types::Strict::String

  def self.decode(database_value)
    payload = JSON.parse(database_value)
    new(
      message: decode64(payload["p"]),
      initialization_vector: decode64(payload.dig("h", "iv")),
      auth_tag: decode64(payload.dig("h", "at"))
    )
  end

  def self.decode64(value)
    Base64.strict_decode64(value)
  end

  def encode
    payload =
      {
        "p" => encode64(message),
        "h" => {
          "iv" => encode64(initialization_vector),
          "at" => encode64(auth_tag)
        }
      }

    JSON.dump(payload)
  end

  private

  def encode64(value)
    Base64.strict_encode64(value)
  end
end
