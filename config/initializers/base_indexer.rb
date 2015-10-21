
# Define the indexer class that will be used by the engine.
# The engine consumer app should override this class
BaseIndexer.indexer_class = 'BaseIndexer::MainIndexerEngine'
BaseIndexer.solr_configuration_class_name = 'BaseIndexer::SolrConfigurationFromFile'
# BaseIndexer.solr_configuration_class.constantize.new(Rails.configuration.solr_config_file_path)
BaseIndexer.mapper_class_name = 'DiscoveryIndexer::Mapper::GeneralMapper'
BaseIndexer.solr_writer_class_name = 'DiscoveryIndexer::Writer::SolrWriter'
