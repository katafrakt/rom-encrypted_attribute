# ROM::EncryptedAttribute

This gem adds support for encrypted attributes to [ROM](https://rom-rb.org/).

Traditionally ROM team [suggested](https://discourse.rom-rb.org/t/question-encryption-support-thoughts/387) to put encryption logic in repository code (more precisely, in the mapper from database struct to an entity). I personally think this is not the greatest idea. Repository lies logically in the application layer (or even domain layer), while encryption and decryption of data is a purely infrastructure concern. As such, it should be as low-level and hidden as possible.

In ROM terms it means doing it in a relation. The gem leverages custom types to achieve encryption and decryption.

The scheme is compatible with Rails' default settings for ActiveRecord encryption, so you can still read records encrypted with ActiveRecord from ROM (and vice versa) as long as you provide the same primary key and key derivation salt.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rom-encrypted_attribute

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rom-encrypted_attribute

## Usage

In your relation, define custom types using a helper method from the gem. You need to provide the credentials to it somehow. This might be done via environmental variables, Hanami settings (if you're using Hanami) or any other means, really.

```ruby
class SecretNotes < ROM::Relation[:sql]
  EncryptedString, EncryptedStringReader =
    ROM::EncryptedAttribute.define_encrypted_attribute_types(
      primary_key: ENV["ENCRYPTION_PRIMARY_KEY"],
      key_derivation_salt: ENV["ENCRYPTION_KEY_DERIVATION_SALT"]
    )
    
  schema(:secret_notes, infer: true) do
    attribute :content, EncryptedString, read: EncryptedStringReader
  end
end
```

By default the gem uses SHA1 for key derivation (same as Rails' default), but you can configure it by passing custom `has_digest_class` option.

``` ruby
class SecretNotes < ROM::Relation[:sql]
  EncryptedString, EncryptedStringReader =
    ROM::EncryptedAttribute.define_encrypted_attribute_types(
      primary_key: ENV["ENCRYPTION_PRIMARY_KEY"],
      key_derivation_salt: ENV["ENCRYPTION_KEY_DERIVATION_SALT"],
      hash_digest_class: OpenSSL::Digest::SHA256
    )
    
  schema(:secret_notes, infer: true) do
    attribute :content, EncryptedString, read: EncryptedStringReader
  end
end

```

### Caveats

* Due to [a bug](https://github.com/rom-rb/rom-sql/issues/423) in `rom-sql`, reading unencrypted data is always supported, which means that if there's a plain not-encrypted data in your database already, it will be read correctly. This might or might not be desirable, but for the time being there's no choice in cofiguring this behaviour.
* Support for deterministic encryption from `ActiveRecord::Encryption` is not implemented
* Support for key rotation is not implemented

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katafrakt/rom-encrypted_attribute.
