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

There are two ways to use this library: via a ROM schema plugin or by a "bare metal" approach.

### ROM plugin

Somewhere in you code set the config for the gem. This is done using [`Dry::Configurable`](https://dry-rb.org/gems/dry-configurable/1.0/), so you can use all options available there. For example:

``` ruby
ROM::EncryptedAttribute.configure do |config|
  config.primary_key = "your-primary-key" # required
  config.key_derivation_salt = "your-derivation-salt" # required
  config.hash_digest_class = OpenSSL::Digest::SHA256 # SHA1 by default
end
```

Then use the plugin in your ROM relation:

``` ruby
class SecretNotes < ::ROM::Relation[:sql]
  schema(:secret_notes, infer: true) do
    use :encrypted_attributes
    encrypt :content
  end
end
```

You can override individual configuration values if, for example, one database table uses different primary key:

``` ruby
class SecretNotes < ::ROM::Relation[:sql]
  schema(:secret_notes, infer: true) do
    use :encrypted_attributes, primary_key: ENV["SPECIAL_PRIMARY_KEY"]
    encrypt :content
  end
end
```

If you specify all configuration options, or use defaults, you can skip setting the global config.

You can also override global per-schema settings on a per-field level:

``` ruby
class SecretNotes < ::ROM::Relation[:sql]
  schema(:secret_notes, infer: true) do
    use :encrypted_attributes
    encrypt :content
    encrypt :title, :hash_digest_class: OpenSSL::Digest::SHA256
    encrypt :maybe_encrypted, support_unencrypted_data: true
  end
end

```

### "Bare metal"

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

With this approach you can define the types globally in your application and reuse it, without having to pass primary_key and key_derivation_salt every time in the schema.

### Other considerations

By default the gem uses SHA1 for key derivation (same as Rails' default), but you can configure it by passing custom `hash_digest_class` option.

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

* Due to [a bug](https://github.com/rom-rb/rom-sql/issues/423) in `rom-sql`, reading unencrypted data requires a monkey patch to ROM. Since this is quite aggressive, you are expected to opt-in to this by calling `ROM::SQL::Patch432.install!`.
* Support for deterministic encryption from `ActiveRecord::Encryption` is not (yet) implemented
* Support for key rotation is not (yet) implemented

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katafrakt/rom-encrypted_attribute.
