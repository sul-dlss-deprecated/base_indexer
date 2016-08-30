require 'singleton'
require 'yaml'

module BaseIndexer
  
  # It reads the solr configuration from YAML file
  class SolrConfigurationFromFile < SolrConfiguration
    include Singleton
    
    # reads the solr yaml configuration file
    # @param yaml_file [String] solr yaml configuration file name
    def read(yaml_file=nil)
      @solr_config_hash = YAML.load_file(yaml_file)
    end
    
     # @return [Hash] hash represents the solr configuration
     # @example
     #   {"target1":{"url"=>"http://localhost/solr/"},"target2":{"url"=>"http://solr-cor.com/solr/"}}
     #
     #   {"target1":{"url"=>"http://localhost/solr/","open_timeout"=>120},"target2":{"url"=>"http://solr-cor.com/solr/"}}
     def get_configuration_hash
       Hash[ @solr_config_hash.collect {|k,v| [k.upcase, v] } ] # updase all of the target names
    end
  end
end