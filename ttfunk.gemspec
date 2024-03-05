# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'ttfunk'
  spec.version = '1.7.0'
  spec.platform = Gem::Platform::RUBY
  spec.summary = 'TrueType Font Metrics Parser'
  spec.description = 'Font Metrics Parser for the Prawn PDF generator'

  spec.files = Dir.glob('lib/**/*') +
    ['CHANGELOG.md', 'README.md', 'COPYING', 'LICENSE', 'GPLv2', 'GPLv3']

  if File.basename($PROGRAM_NAME) == 'gem' && ARGV.include?('build')
    signing_key = File.expand_path('~/.gem/gem-private_key.pem')
    if File.exist?(signing_key)
      spec.cert_chain = ['certs/pointlessone.pem']
      spec.signing_key = signing_key
    else
      warn 'WARNING: Signing key is missing. The gem is not signed and its authenticity can not be verified.'
    end
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
  spec.homepage = 'http://prawnpdf.org/'
  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'homepage_uri' => spec.homepage,
    'changelog_uri' => "https://github.com/prawnpdf/ttfunk/blob/#{spec.version}/CHANGELOG.md",
    'source_code_uri' => 'https://github.com/prawnpdf/ttfunk',
    'documentation_uri' => "https://prawnpdf.org/docs/ttfunk/#{spec.version}/",
    'bug_tracker_uri' => 'https://github.com/prawnpdf/ttfunk/issues',
  }

  spec.required_ruby_version = '>= 2.7'
  spec.add_runtime_dependency('bigdecimal', '~> 3.1')
  spec.add_development_dependency('prawn-dev', '~> 0.4.0')
end
