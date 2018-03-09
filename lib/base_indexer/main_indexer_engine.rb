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
    # It is the main indexing function
    #
    # @param druid [String] is the druid for an object e.g., ab123cd4567
    # @param targets [Array] is an array with the targets list to index towards
    #
    # @raise it will raise erros if there is any problems happen in any level
    def index(druid, targets)
      # Map the input to solr_doc
      solr_doc = mapper_class.new(druid).convert_to_solr_doc

      # Get SOLR configuration and write
      solr_writer.process(druid, solr_doc, targets)
    end

    # It deletes an item defined by druid from all registered solr core
    # @param druid [String] is the druid for an object e.g., ab123cd4567
    def delete(druid)
      solr_writer.solr_delete_from_all(druid)
    end

    private

    def mapper_class
      BaseIndexer.mapper_class_name.constantize
    end

    def solr_writer
      BaseIndexer::Solr::Writer.new
    end
  end
end
