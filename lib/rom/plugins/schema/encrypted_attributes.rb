# frozen_string_literal: true

require "rom"

module ROM
  module Plugins
    module Schema
      module EncryptedAttributes
        def self.apply(schema, **options)
          attributes = options.fetch(:attributes)
          primary_key = options.fetch(:primary_key, ROM::EncryptedAttribute.config.primary_key)
          key_derivation_salt = options.fetch(:key_derivation_salt, ROM::EncryptedAttribute.config.key_derivation_salt)
          hash_digest_class = options.fetch(:hash_digest_class, ROM::EncryptedAttribute.config.hash_digest_class)
          support_unencrypted_data = options.fetch(:support_unencrypted_data, EncryptedAttribute.config.support_unencrypted_data)

          encrypted_string, encrypted_string_reader =
            ROM::EncryptedAttribute.define_encrypted_attribute_types(
              primary_key: primary_key, key_derivation_salt: key_derivation_salt, hash_digest_class: hash_digest_class, support_unencrypted_data: support_unencrypted_data
            )

          attrs =
            attributes.map do |name|
              ROM::Schema::DSL.new(schema.name).build_attribute_info(
                name,
                encrypted_string,
                name: name, read: encrypted_string_reader
              )
            end

          schema.attributes.concat(
            schema.class.attributes(attrs, schema.attr_class)
          )
        end

        module DSL
          # @example
          #   schema do
          #     use :encrypted_attributes
          #     encrypt :api_key, :ssn, hash_digest_class: OpenSSL::Digest::SHA256
          #   end
          def encrypt(*attributes, **opts)
            options = plugin_options(:encrypted_attributes)
            options.merge!(opts)
            options[:attributes] ||= []
            options[:attributes] += attributes
            self
          end
        end
      end
    end
  end
end

ROM.plugins do
  register :encrypted_attributes, ROM::Plugins::Schema::EncryptedAttributes, type: :schema
end
