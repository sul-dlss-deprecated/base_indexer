require "base_indexer/engine"

require "base_indexer/main_indexer_engine"
require "base_indexer/solr_configuration"
require "base_indexer/solr_configuration_from_file"
require "base_indexer/collections"
require 'discovery-indexer'
module BaseIndexer
  mattr_accessor :indexer_class
  mattr_accessor :solr_configuration_class
end

