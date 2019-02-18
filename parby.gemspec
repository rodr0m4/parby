# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require 'parby/version'

Gem::Specification.new do |s|
  s.name = 'parby'
  s.version = Parby::VERSION
  s.date = '2019-02-17'
  s.summary = 'Happy little parser combinators'
  s.authors = ['Rodrigo Martin']
  s.email = 'rodrigoleonardomartin@gmail.com'
  s.files = `git ls-files`.split("\n")
  s.metadata = { "source_code_uri" => "https://github.com/rodr0m4/parby" }
  s.license = 'MIT'

  s.add_development_dependency 'rspec', '~> 3.0'
end
