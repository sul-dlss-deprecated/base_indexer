require 'rails/generators'

module BaseIndexer
  class Install < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc 'Install Base Indexer'

    def assets
      copy_file 'solr.yml', 'config/solr.yml'
    end

    def add_routes
      route "mount BaseIndexer::Engine, at: '/'"
    end
  end
end
