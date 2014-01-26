# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "capistrano-runit"
  gem.version       = "0.1.0"
  gem.authors       = ["Matt Mihic"]
  gem.email         = ["matt@mpath.com"]
  gem.homepage      = "https://github.com/mpath-development/capistrano-runit"
  gem.summary       = %q{Commands for managing runit via Capistrano}
  gem.description   = %q{Provides a set of commands for configuring runit with your application}

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('capistrano', '>=2.1.0')
end
