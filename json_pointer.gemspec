# frozen_string_literal: true

require_relative "lib/json_pointer/version"

Gem::Specification.new do |spec|
  spec.name = "json_pointer"
  spec.version = JSONPointer::VERSION
  spec.authors = ["William Saylor"]
  spec.email = ["w@saylo.rs"]

  spec.summary = "A Ruby implementation of RFC 6901: JavaScript Object Notation (JSON) Pointer"
  spec.homepage = "https://github.com/wasaylor/json_pointer"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = %w[lib/json_pointer/version.rb lib/json_pointer.rb]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest"
end
