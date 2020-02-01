lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asciibook/version'

Gem::Specification.new do |spec|
  spec.name          = "asciibook"
  spec.version       = Asciibook::VERSION
  spec.authors       = ["Rei"]
  spec.email         = ["chloerei@gmail.com"]

  spec.summary       = %q{}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir.glob('{bin,exe,lib,templates,theme}/**/*') + %w(LICENSE.txt README.adoc)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "asciidoctor", "~> 2.0"
  spec.add_runtime_dependency "liquid", "~> 4.0"
  spec.add_runtime_dependency "gepub", "~> 1.0"
  spec.add_runtime_dependency "mercenary"
  spec.add_runtime_dependency "rouge"
  spec.add_runtime_dependency "nokogiri"
end
