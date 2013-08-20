# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cieloz/version'

Gem::Specification.new do |gem|
  gem.name          = "cieloz"
  gem.version       = Cieloz::VERSION
  gem.authors       = ["Fábio Luiz Nery de Miranda"]
  gem.email         = ["fabio@miranti.net.br"]
  gem.description   = %q{A utility gem for Cielo Integration}
  gem.summary       = %q{}
  gem.homepage      = "https://github.com/fabiolnm/cieloz"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "nokogiri"
  gem.add_dependency "activesupport"
  gem.add_dependency "activemodel"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "turn"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "webmock"

  gem.add_development_dependency "debugger"
  gem.add_development_dependency "shoulda-matchers"
  gem.add_development_dependency "minitest-matchers"
end
