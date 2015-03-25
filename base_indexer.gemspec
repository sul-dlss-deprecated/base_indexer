$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "base_indexer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "base_indexer"
  s.version     = BaseIndexer::VERSION
  s.authors     = ["Ahmed Alsum"]
  s.email       = ["aalsum@stanford.edu"]
  s.summary     = "Summary of BaseIndexer."
  s.description = "Description of BaseIndexer."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
 
  s.add_dependency "rails", "~> 4.1.9"
  s.add_dependency 'discovery-indexer'

  s.add_development_dependency "mysql2"
end
