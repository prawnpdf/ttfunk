Gem::Specification.new do |spec|
  spec.name = 'ttfunk'
  spec.version = '1.0.0'
  spec.platform = Gem::Platform::RUBY
  spec.summary = "TrueType Font Metrics Parser"
  spec.description = "Get Ya TrueType Funk On! (Font Metrics Parser for Prawn)"

  spec.files =  Dir.glob("{lib,data,examples}/**/*") + ['CHANGELOG','README.rdoc']
  spec.required_ruby_version = '>= 1.8.7'
  spec.required_rubygems_version = ">= 1.3.6"

  spec.authors = ["Gregory Brown","Brad Ediger", "Daniel Nelson","Jonathen Green","James Healy"]
  spec.email = ["gregory.t.brown@gmail.com","brad@bradediger.com","dnelson77@gmail.com", "greenberg@entryway.net","jimmy@deefa.com"]
end
