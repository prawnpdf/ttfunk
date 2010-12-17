Gem::Specification.new do |spec|
  spec.name = 'ttfunk'
  spec.version = '0.1.0'
  spec.platform = Gem::Platform::RUBY
  spec.summary = "Font Metrics Parser for Prawn"
  spec.description = "Get Ya TrueType Funk On! (Font Metrics Parser for Prawn)"

  spec.files =  Dir.glob("{lib,data}/**/*") + ['example.rb', 'ttfunk.gemspec']
  spec.require_path = 'lib'
  spec.required_ruby_version = '>= 1.8.7'
  spec.required_rubygems_version = ">= 1.3.6"

  spec.author = "Gregory Brown"
  spec.email = "gregory.t.brown@gmail.com"
end
