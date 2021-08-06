lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vending_machine/version'

Gem::Specification.new do |gem|
  gem.required_ruby_version = ">= 2.7"

  gem.name          = "vending_machine"
  gem.version       = VendingMachine::VERSION
  gem.authors       = ["Dmytro Vasin"]
  gem.email         = ["dmytro.vasin@gmail.com"]

  gem.summary       = "Vending Machine"
  gem.description   = "Virtual vending machine application which emulates the goods buying operations and change calculation."
  gem.homepage      = "https://github.com/DmytroVasin/vending_machine/"
  gem.license       = "MIT"

  gem.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  # gem.bindir        = "exe"
  # gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.executables = ["vm"]
  gem.require_paths = ["lib"]

  gem.add_dependency "tty-prompt", "0.23.1"

  gem.add_development_dependency "bundler", "~> 2.1.2"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "rspec", "~> 3.6.0"
end
