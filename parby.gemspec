Gem::Specification.new do |s|
  s.name = 'parby'
  s.version = '0.2.0'
  s.date = '2019-02-17'
  s.summary = 'Happy little parser combinators'
  s.authors = ['Rodrigo Martin']
  s.email = 'rodrigoleonardomartin@gmail.com'
  s.files = ['lib/combinators.rb', 'lib/parser.rb', 'lib/result.rb']
  s.metadata = { "source_code_uri" => "https://github.com/rodr0m4/parby" }
  s.license = 'MIT'

  s.add_development_dependency 'rspec', '~> 3.0'
end
