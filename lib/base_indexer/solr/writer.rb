require 'retries'
require 'rsolr'

module BaseIndexer
  module Solr
    # Performs writes to solr client based upon true and false release flags
    class Writer
      attr_reader :solr_targets_configs

      include DiscoveryIndexer::Logging

      def process(id, index_doc, targets, targets_configs)
        @solr_targets_configs = targets_configs
        index_targets = targets.select { |_, b| b }.keys
        delete_targets = targets.reject { |_, b| b }.keys

        # get targets with true
        solr_index_client(id, index_doc, index_targets) if index_targets.present?
        # get targets with false
        solr_delete_client(id, delete_targets) if delete_targets.present?
      end

      def solr_delete_from_all(id, targets_configs)
        # Get a list of all registered targets
        @solr_targets_configs = targets_configs
        targets = solr_targets_configs.keys
        solr_delete_client(id, targets)
      end

      def solr_index_client(id, index_doc, targets)
        targets.each do |solr_target|
          solr_connector = get_connector_for_target(solr_target)
          Client.add(id, index_doc, solr_connector) unless solr_connector.nil?
        end
      end

      def solr_delete_client(id, targets)
        targets.each do |solr_target|
          solr_connector = get_connector_for_target(solr_target)
          Client.delete(id, solr_connector) unless solr_connector.nil?
        end
      end

      def get_connector_for_target(solr_target)
        solr_connector = nil
        unless solr_targets_configs.nil?
          if solr_targets_configs.keys.include?(solr_target)
            config = solr_targets_configs[solr_target]
            solr_connector = RSolr.connect(config.deep_symbolize_keys)
          end
        end
        solr_connector
      end
    end
  end
end
