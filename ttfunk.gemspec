# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'ttfunk'
  spec.version = '1.7.0'
  spec.platform = Gem::Platform::RUBY
  spec.summary = 'TrueType Font Metrics Parser'
  spec.description = 'Font Metrics Parser for the Prawn PDF generator'

  spec.homepage = 'https://prawnpdf.org'
  spec.metadata = {
    'rubygems_mfa_required' => 'true',
  }

  signing_key = File.expand_path('~/.gem/gem-private_key.pem')
  if File.exist?(signing_key)
    spec.cert_chain = ['certs/pointlessone.pem']
    if $PROGRAM_NAME.end_with?('gem')
      spec.signing_key = signing_key
    end
  else
    warn 'WARNING: Signing key is missing. The gem is not signed and its authenticity can not be verified.'
  end

  spec.authors = [
    'Alexander Mankuta',
    'Gregory Brown',
    'Brad Ediger',
    'Daniel Nelson',
    'Jonathan Greenberg',
    'James Healy',
    'Cameron Dutro',
  ]
  spec.email = [
    'alex@pointless.one',
    'gregory.t.brown@gmail.com',
    'brad@bradediger.com',
    'dnelson@bluejade.com',
    'greenberg@entryway.net',
    'jimmy@deefa.com',
    'camertron@gmail.com',
  ]
  spec.licenses = %w[Nonstandard GPL-2.0-only GPL-3.0-only]

  spec.files = Dir.glob('lib/**/*') +
    ['CHANGELOG.md', 'README.md', 'COPYING', 'LICENSE', 'GPLv2', 'GPLv3']
  spec.required_ruby_version = '>= 2.7'
  spec.add_runtime_dependency('bigdecimal', '~> 3.1')
  spec.add_development_dependency('prawn-dev', '~> 0.4.0')
end
