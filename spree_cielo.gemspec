# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spree_cielo/version'

Gem::Specification.new do |gem|
  gem.name          = "spree_cielo"
  gem.version       = SpreeCielo::VERSION
  gem.authors       = ["Fábio Luiz Nery de Miranda"]
  gem.email         = ["fabio@miranti.net.br"]
  gem.description   = %q{A Spree Gateway for Cielo}
  gem.summary       = %q{}
  gem.homepage      = "https://github.com/fabiolnm/spree_cielo"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "turn"
  gem.add_development_dependency "debugger"
  gem.add_development_dependency "activesupport"
end
