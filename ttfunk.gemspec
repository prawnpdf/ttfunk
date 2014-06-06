Gem::Specification.new do |spec|
  spec.name = 'ttfunk'
  spec.version = '1.1.1'
  spec.platform = Gem::Platform::RUBY
  spec.summary = "TrueType Font Metrics Parser"
  spec.description = "Get Ya TrueType Funk On! (Font Metrics Parser for Prawn)"

  spec.files =  Dir.glob("{lib,data,examples}/**/*") +
    ['CHANGELOG', 'README.rdoc', 'COPYING', 'LICENSE', 'GPLv2', 'GPLv3']
  spec.required_ruby_version = '>= 1.9.3'
  spec.add_development_dependency('rdoc')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.20.1')

  spec.authors = ["Gregory Brown","Brad Ediger","Daniel Nelson",
    "Jonathan Greenberg","James Healy"]
  spec.email = ["gregory.t.brown@gmail.com","brad@bradediger.com",
    "dnelson@bluejade.com","greenberg@entryway.net","jimmy@deefa.com"]
end
