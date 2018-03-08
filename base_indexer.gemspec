$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'base_indexer/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'base_indexer'
  s.version     = BaseIndexer::VERSION
  s.authors     = ['Ahmed Alsum','Laney McGlohon']
  s.email       = ['laneymcg@stanford.edu']
  s.summary     = 'Summary of BaseIndexer.'
  s.description = 'Description of BaseIndexer.'
  s.license     = 'Apache 2'

  s.files         = `git ls-files -z`.split("\x0")
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency 'rails', '~> 5'
  s.add_dependency 'discovery-indexer', '>= 2', '< 4'
  s.add_dependency 'retries'
  s.add_dependency 'dor-fetcher'
  s.add_dependency 'config'

  s.add_development_dependency 'sqlite3'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'yard' # for documentation

  s.add_development_dependency 'engine_cart'
  s.add_development_dependency 'jettywrapper'
end
