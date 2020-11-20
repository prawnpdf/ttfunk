# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'ttfunk'
  spec.version = '1.6.2.1'
  spec.platform = Gem::Platform::RUBY
  spec.summary = 'TrueType Font Metrics Parser'
  spec.description = 'Font Metrics Parser for the Prawn PDF generator'
  spec.licenses = %w[Nonstandard GPL-2.0 GPL-3.0]

  spec.homepage = 'https://prawnpdf.org'

  spec.cert_chain = ['certs/pointlessone.pem']
  if $PROGRAM_NAME.end_with? 'gem'
    spec.signing_key = File.expand_path('~/.gem/gem-private_key.pem')
  end

  spec.authors = [
    'Gregory Brown',
    'Brad Ediger',
    'Daniel Nelson',
    'Jonathan Greenberg',
    'James Healy',
    'Cameron Dutro'
  ]
  spec.email = [
    'gregory.t.brown@gmail.com',
    'brad@bradediger.com',
    'dnelson@bluejade.com',
    'greenberg@entryway.net',
    'jimmy@deefa.com',
    'camertron@gmail.com'
  ]

  spec.files = Dir.glob('lib/**/*') +
    ['CHANGELOG.md', 'README.md', 'COPYING', 'LICENSE', 'GPLv2', 'GPLv3']
  spec.required_ruby_version = '>= 2.4'
  spec.add_development_dependency('rake', '~> 12')
  spec.add_development_dependency('rspec', '~> 3.5')
  spec.add_development_dependency('rubocop', '~> 0.68')
  spec.add_development_dependency('rubocop-performance', '~> 1.1')
  spec.add_development_dependency('rubocop-rspec', '~> 1.32')
  spec.add_development_dependency('yard', '~> 0.9')
end
