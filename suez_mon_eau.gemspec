# encoding: utf-8
# frozen_string_literal: true

require_relative 'lib/suez_mon_eau'

# expected extension of gemspec file
GEMSPEC_EXT = '.gemspec'
# see https://guides.rubygems.org/specification-reference/
Gem::Specification.new do |spec|
  # get location of this file (shall be in project root)
  gemspec_file = File.expand_path(__FILE__)
  raise "Error: this file extension must be '#{GEMSPEC_EXT}'" unless gemspec_file.end_with?(GEMSPEC_EXT)
  raise "This file shall be named: #{SuezMonEau::GEM_NAME}#{GEMSPEC_EXT}" unless
    SuezMonEau::GEM_NAME.eql?(File.basename(gemspec_file,GEMSPEC_EXT).downcase)
  # the base name of this file shall be the gem name
  spec.name          = SuezMonEau::GEM_NAME
  spec.version       = SuezMonEau::VERSION
  spec.authors       = ['Laurent Martin']
  spec.email         = ['laurent.martin.l@gmail.com']
  spec.summary       = 'API for www.toutsurmoneau.fr'
  spec.description   = <<-EOF
    This API provides allows access to water usage information from www.toutsurmoneau.fr .
    All is needed is to provide your portal credentials.
    Optionally the counter identifier can be provided, else it is also read from the portal.
  EOF
  spec.homepage      = SuezMonEau::SRC_URL
  spec.license       = 'Apache-2.0'
  spec.requirements << 'No specific requirement'
  raise 'RubyGems 2.0 or newer is required' unless spec.respond_to?(:metadata)
  spec.metadata['allowed_push_host'] = 'https://rubygems.org' # push only to rubygems.org
  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = spec.homepage
  spec.metadata['changelog_uri']     = spec.homepage
  spec.metadata['rubygems_uri']      = SuezMonEau::GEM_URL
  spec.metadata['documentation_uri'] = SuezMonEau::DOC_URL
  spec.require_paths = ['lib']
  spec.bindir        = 'bin'
  # list git files from specified location in root folder of project (this gemspec is in project root folder)
  spec.files = Dir.chdir(File.dirname(gemspec_file)){%x(git ls-files -z lib bin).split("\x0")}
  # specify executable names: must be after lines defining: spec.bindir and spec.files
  spec.executables = spec.files.grep(%r{^#{spec.bindir}}){|f|File.basename(f)}
  spec.cert_chain  = ["certs/laurent.cert.pem"]
  # SIGNING_KEY contains the path to private key file
  spec.signing_key = File.expand_path(ENV.fetch('SIGNING_KEY')) if ENV.has_key?('SIGNING_KEY')
  # see also SuezMonEau::RUBY_FUTURE_MINIMUM_VERSION
  spec.required_ruby_version = '>= 2.4'
  # dependency gems for runtime
  spec.add_runtime_dependency('rest-client', '~> 2.0')
  # development gems
  spec.add_development_dependency('bundler', '~> 2.0')
  spec.add_development_dependency('rubocop', '~> 1.12')
  spec.add_development_dependency('rubocop-ast', '~> 1.4')
  spec.add_development_dependency('rubocop-performance', '~> 1.10')
  spec.add_development_dependency('rubocop-shopify', '~> 2.0')
  spec.add_development_dependency('simplecov', '~> 0.18')
  spec.add_development_dependency('solargraph', '~> 0.44')
end
