module BaseIndexer
  
  # It is an interface to load the solr configuration hash
  class SolrConfiguration
    
    # It reads the configuration argument. This function is loaded by default when the 
    # base_indexer_engine is loading
    def read(default_arg=nil)
    end
    
    # @return [Hash] hash represents the solr configuration
    # @example
    #   {"target1":{"url"=>"http://localhost/solr/"},"target2":{"url"=>"http://solr-cor.com/solr/"}}
    def get_configuration_hash
    end
  end
end