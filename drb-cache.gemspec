# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'drb/cache/version'

Gem::Specification.new do |spec|
  spec.name          = 'drb-cache'
  spec.version       = DRb::Cache::VERSION
  spec.authors       = ['Konstantin Gredeskoul', 'Nathan Hopkins']
  spec.email         = %w(kigster@gmail.com natehop@gmail.com)
  spec.summary       = 'Basic memcached-like caching without the memcached dependency based on DRb'
  spec.description   = 'Store values in this cache across multiple ruby processes, while transparently starting dRb server when needed.'
  spec.homepage      = 'https://github.com/kigster/drb-cache'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
end
