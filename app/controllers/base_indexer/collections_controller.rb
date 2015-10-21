require_dependency 'base_indexer/application_controller'

module BaseIndexer
  class CollectionsController < ApplicationController
    def new
      druid = remove_prefix params[:druid]

      Rails.logger.debug "Receiving indexing of collection #{druid}"
      targets = params[:subtargets]

      # initial collection item itself
      indexer = BaseIndexer.indexer_class.constantize.new
      indexer.index druid, targets

      # initialize dor-fetcher to get list of druids for this collection
      df = DorFetcher::Client.new(service_url: Rails.application.config.dor_fetcher_url)

      item_druids = df.druid_array(df.get_collection(druid, {}))

      Rails.logger.debug "Found #{item_druids.size} members of the collection #{druid}"

      counter = 0

      item_druids.each do |druid|
        druid = remove_prefix druid
        counter += 1
        indexer.index druid, targets
        Rails.logger.debug "#{counter} of #{item_druids.size}: #{druid}"
      end

      @status = report_success
      render nothing: true, status: 200
      Rails.logger.debug "Completing indexing of collection #{druid}"

    rescue Exception => e
      @status = report_failure request.method_symbol, params, e
      Rails.logger.error @status
      render nothing: true, status: 202
    end
  end
end
