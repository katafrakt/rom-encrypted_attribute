# RomEncryptedAttribute

This gem adds support for encrypted attributes to [ROM](https://rom-rb.org/).

Traditionally ROM team [suggested](https://discourse.rom-rb.org/t/question-encryption-support-thoughts/387) to put encryption logic in repository code (more precisely, in the mapper from database struct to an entity). I personally think this is not the greatest idea. Repository lies logically in the application layer (or even domain layer), while encryption and decryption of data is a purely infrastructure concern. As such, it should be as low-level and hidden as possible.

In ROM terms it means doing it in a relation. The gem leverages custom types to achieve encryption and decryption.

The scheme is compatible with Rails' default settings for ActiveRecord encryption, so you can still read records encrypted with ActiveRecord from ROM (and vice versa) as long as you provide the same primary key and key derivation salt.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rom_encrypted_attribute

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rom_encrypted_attribute

## Usage

In your relation, define custom types using a helper method from the gem. You need to provide the credentials to it somehow. This might be done via environmental variables, Hanami settings (if you're using Hanami) or any other means, really.

```ruby
class SecretNotes < ROM::Relation[:sql]
  EncryptedString, EncryptedStringReader =
    RomEncryptedAttribute.define_encrypted_attribute_types(
      primary_key: ENV["ENCRYPTION_PRIMARY_KEY"],
      derivation_salt: ENV["ENCRYPTION_DERIVATION_SALT"]
    )
    
  schema(:secret_notes, infer: true) do
    attribute :content, EncryptedString, read: EncryptedStringReader
  end
end
```

Of course, you can define it somewhere else and just `include` in the relation or use your custom types code organization.

### Caveats

* Due to a bug in `rom-sql`, reading unencrypted data is turned on by default
* The gem uses SHA256 for key derivation and it's currently not configurable
* Support for deterministic encryption from `ActiveRecord::Encryption` is not implemented

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katafrakt/rom_encrypted_attribute.
