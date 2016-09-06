require 'retries'
require 'rsolr'
require 'rest-client'
module BaseIndexer
  module Solr
    # Processes adds and deletes to the solr core
    class Client
      include DiscoveryIndexer::Logging

      # Add the document to solr, retry if an error occurs.
      # See https://github.com/ooyala/retries for docs on with_retries.
      # @param id [String] the document id, usually it will be druid.
      # @param solr_doc [Hash] a Hash representation of the solr document
      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      # @param max_retries [Integer] the maximum number of tries before fail
      def self.add(id, solr_doc, solr_connector, max_retries = 10)
        process(id, solr_doc, solr_connector, max_retries, false)
      end

      # Add the document to solr, retry if an error occurs.
      # See https://github.com/ooyala/retries for docs on with_retries.
      # @param id [String] the document id, usually it will be druid.
      # @param solr_connector[RSolr::Client]  is an open connection with the solr core
      # @param max_retries [Integer] the maximum number of tries before fail
      def self.delete(id, solr_connector, max_retries = 10)
        process(id, {}, solr_connector, max_retries, true)
      end

      # It's an internal method that receives all the requests and deal with
      # SOLR core. This method can call add, delete, or update
      #
      # @param id [String] the document id, usually it will be druid.
      # @param solr_doc [Hash] is the solr doc in hash format
      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      # @param max_retries [Integer] the maximum number of tries before fail
      def self.process(id, solr_doc, solr_connector, max_retries, is_delete = false)
        handler = proc do |exception, attempt_number, _total_delay|
          DiscoveryIndexer::Logging.logger.error "#{exception.class} on attempt #{attempt_number} for #{id}"
        end

        with_retries(max_tries: max_retries, handler: handler, base_sleep_seconds: 1, max_sleep_seconds: 5) do |attempt|
          DiscoveryIndexer::Logging.logger.debug "Attempt #{attempt} for #{id}"

          if is_delete
            DiscoveryIndexer::Logging.logger.info "Deleting #{id} on attempt #{attempt}"
            solr_connector.delete_by_id(id, :add_attributes => {:commitWithin => 10000})
          elsif allow_update?(solr_connector) && doc_exists?(id, solr_connector)
            DiscoveryIndexer::Logging.logger.info "Updating #{id} on attempt #{attempt}"
            update_solr_doc(id, solr_doc, solr_connector)
          else
            DiscoveryIndexer::Logging.logger.info "Indexing #{id} on attempt #{attempt}"
            solr_connector.add(solr_doc, :add_attributes => {:commitWithin => 10000})
          end
          #solr_connector.commit
          DiscoveryIndexer::Logging.logger.info "Completing #{id} successfully on attempt #{attempt}"
        end
      end

      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      # @return [Boolean] true if the solr core allowing update feature
      def self.allow_update?(solr_connector)
        solr_connector.options.include?(:allow_update) ? solr_connector.options[:allow_update] : false
      end

      # @param id [String] the document id, usually it will be druid.
      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      # @return [Boolean] true if the solr doc defined by this id exists
      def self.doc_exists?(id, solr_connector)
        response = solr_connector.get 'select', params: { q: 'id:"' + id + '"' }
        response['response']['numFound'] == 1
      end

      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      # send hard commit to solr
      def self.commit(solr_connector)
        RestClient.post self.solr_url(solr_connector), {},:content_type => :json, :accept=>:json
      end

      # It is an internal method that updates the solr doc instead of adding a new one.
      # @param id [String] the document id, usually it will be druid.
      # @param solr_doc [Hash] is the solr doc in hash format
      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      def self.update_solr_doc(id, solr_doc, solr_connector)
        # update_solr_doc can't used RSolr because updating hash doc is not supported
        #  so we need to build the json input manually
        params = "[{\"id\":\"#{id}\","
        solr_doc.each do |field_name, new_values|
          next if field_name == :id
          params += "\"#{field_name}\":"
          new_values = [new_values] unless new_values.class == Array
          new_values = new_values.map { |s| s.to_s.gsub('\\', '\\\\\\').gsub('"', '\"').strip } # strip leading/trailing spaces and escape quotes for each value
          params += "{\"set\":[\"#{new_values.join('","')}\"]},"
        end
        params.chomp!(',')
        params += '}]'
        RestClient.post self.solr_url(solr_connector), params, content_type: :json, accept: :json
      end

      # adjust the solr_url so it works with or without a trailing /
      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      # @return [String] the solr URL
      def self.solr_url(solr_connector)
        solr_url = solr_connector.options[:url]
        if solr_url.end_with?('/')
          "#{solr_url}update?commit=true"
        else
          "#{solr_url}/update?commit=true"
        end
      end

    end
  end
end
