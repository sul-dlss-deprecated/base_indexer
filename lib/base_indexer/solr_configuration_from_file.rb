require 'singleton'
require 'yaml'

module BaseIndexer
  class SolrConfigurationFromFile < SolrConfiguration
    include Singleton
    
    def read(yaml_file=nil)
      @solr_config_hash = YAML.load_file(yaml_file)
    end
    
    def get_configuration_hash
      @solr_config_hash
    end
  end
end