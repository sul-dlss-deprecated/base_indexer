require 'retries'
require 'rsolr'

module BaseIndexer
  module Solr
    # Performs writes to solr client based upon true and false release flags
    class Writer
      include DiscoveryIndexer::Logging

      def process(id, index_doc, targets)
        index_targets = targets.select { |_, b| b }.keys
        delete_targets = targets.reject { |_, b| b }.keys

        # get targets with true
        solr_index_client(id, index_doc, index_targets)
        # get targets with false
        solr_delete_client(id, delete_targets)
      end

      def solr_delete_from_all(id)
        # Get a list of all registered targets
        targets = solr_targets_configs.keys
        solr_delete_client(id, targets)
      end

      def get_connector_for_target(solr_target)
        solr_connector_targets[solr_target]
      end

      private

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

      def solr_connector_targets
        @solr_connector_targets ||= begin
          solr_targets_configs.transform_values do |config|
            RSolr.connect(config.deep_symbolize_keys)
          end
        end
      end

      def solr_targets_configs
        Settings.SOLR_TARGETS.to_hash.stringify_keys
      end
    end
  end
end
