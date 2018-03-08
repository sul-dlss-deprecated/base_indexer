require_dependency 'base_indexer/application_controller'

module BaseIndexer
  class CollectionsController < ApplicationController
    def update
      druid = remove_prefix params[:id]

      Rails.logger.debug "Receiving indexing of collection #{druid}"
      targets = params[:subtargets]

      # initial collection item itself
      indexer = BaseIndexer.indexer_class.constantize.new
      indexer.index druid, targets

      # Determine collection item druids
      fetcher = BaseIndexer.fetcher_class.constantize.new(service_url: Rails.application.config.fetcher_url)
      item_druids = fetcher.druid_array(fetcher.get_collection(druid, {}))

      Rails.logger.debug "Found #{item_druids.size} members of the collection #{druid}"

      counter = 0

      item_druids.each do |idruid|
        druid = remove_prefix idruid
        counter += 1
        indexer.index druid, targets
        Rails.logger.debug "#{counter} of #{item_druids.size}: #{druid}"
      end

      @status = report_success
      head :ok
      Rails.logger.debug "Completing indexing of collection #{druid}"

    rescue Exception => e
      @status = report_failure request.method_symbol, params, e
      Rails.logger.error @status
      raise
    end
  end
end
