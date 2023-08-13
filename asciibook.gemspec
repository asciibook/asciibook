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

  spec.files         = Dir.glob('{bin,exe,lib,templates,theme,book_template}/**/*') + %w(LICENSE.txt README.adoc)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "asciidoctor", "~> 2.0"
  spec.add_runtime_dependency "asciidoctor-mathematical", "~> 0.3"
  spec.add_runtime_dependency "mathematical", "1.6.14"
  spec.add_runtime_dependency "liquid", "~> 5.0"
  spec.add_runtime_dependency "gepub", "~> 1.0"
  spec.add_runtime_dependency "mercenary", "~> 0.4"
  spec.add_runtime_dependency "rouge", "~> 4.0"
  spec.add_runtime_dependency "nokogiri", "~> 1.0"

  spec.add_development_dependency "rake"
end
