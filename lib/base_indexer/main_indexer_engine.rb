require 'discovery-indexer'
module BaseIndexer
  # It is responsible for performing the basic indexing steps, it includes reading
  # the input from PURL server, getting collection names, mapping it to solr doc hash,
  # and write it to SOLR core . It can also delete the object from all the registered
  #
  # @example Index with target list
  #   indexer = BaseIndexer::MainIndexerEngine.new
  #   indexer.index "ab123cd456", ["searchworks","revs"]
  #
  # @example Index from release_tags
  #   indexer = BaseIndexer::MainIndexerEngine.new
  #   indexer.index "ab123cd456"
  #
  # @example Delete item from all solr cores
  #   indexer = BaseIndexer::MainIndexerEngine.new
  #   indexer.delete "ab123cd456"
  class MainIndexerEngine
    include DiscoveryIndexer

    # It is the main indexing function
    #
    # @param druid [String] is the druid for an object e.g., ab123cd4567
    # @param targets [Array] is an array with the targets list to index towards,
    #   if it is nil, the method will read the target list from release_tags
    #
    # @raise it will raise erros if there is any problems happen in any level
    def index(druid, targets = nil)
      # Map the input to solr_doc
      solr_doc = BaseIndexer.mapper_class_name.constantize.new(druid).convert_to_solr_doc

      # Get SOLR configuration and write
      BaseIndexer.solr_writer_class_name.constantize.new
                 .process(druid, solr_doc, targets, Settings.SOLR_TARGETS.to_hash.deep_stringify_keys)
    end

    # It deletes an item defined by druid from all registered solr core
    # @param druid [String] is the druid for an object e.g., ab123cd4567
    def delete(druid)
      BaseIndexer.solr_writer_class_name.constantize.new
                 .solr_delete_from_all(druid, Settings.SOLR_TARGETS.to_hash.deep_stringify_keys)
    end

  end
end
