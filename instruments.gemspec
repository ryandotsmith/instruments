# -*- encoding: utf-8 -*-
require File.expand_path('../lib/instruments/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ryan Smith (ace hacker)"]
  gem.email         = ["ryan@heroku.com"]
  gem.description   = "Instruments for popular libraries"
  gem.summary       = "Instrument your code"
  gem.homepage      = "http://github.com/ryandotsmith/instruments"
  gem.date          = "2012-04-07"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "instruments"
  gem.require_paths = ["lib"]
  gem.version       = Instruments::VERSION
end
