require 'rails/generators'

module BaseIndexer
  ##
  # base_indexer:install generator
  class Install < Rails::Generators::Base
  	def inject_base_indexer_routes
      route "mount BaseIndexer::Engine, at: '/items'"
    end
  end
end