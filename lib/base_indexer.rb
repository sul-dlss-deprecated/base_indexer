require 'base_indexer/engine'

require 'base_indexer/main_indexer_engine'
require 'base_indexer/solr/client'
require 'base_indexer/solr/writer'
require 'discovery-indexer'
module BaseIndexer
  mattr_accessor :indexer_class
  mattr_accessor :mapper_class_name
  mattr_accessor :solr_writer_class_name
  mattr_accessor :fetcher_class
end
