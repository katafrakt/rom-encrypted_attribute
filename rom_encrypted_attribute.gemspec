# frozen_string_literal: true

require_relative "lib/rom_encrypted_attribute/version"

Gem::Specification.new do |spec|
  spec.name = "rom_encrypted_attribute"
  spec.version = RomEncryptedAttribute::VERSION
  spec.authors = ["Paweł Świątkowski"]
  spec.email = ["katafrakt@vivaldi.net"]

  spec.summary = "Encrypted attributes for ROM"
  spec.required_ruby_version = ">= 3.0.0"
  spec.metadata["source_code_uri"] = "https://github.com/katafrakt/rom_encrypted_attribute"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "dry-types", "~> 1.5"

  spec.add_development_dependency "activerecord", ">= 7.0"
  spec.add_development_dependency "rom-sql", ">= 3.0"
  spec.add_development_dependency "sqlite3", ">= 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
