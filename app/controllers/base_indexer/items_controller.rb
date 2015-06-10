require_dependency "base_indexer/application_controller"

module BaseIndexer
  class ItemsController < ApplicationController

    def new
      begin  
        druid = remove_prefix params[:druid]
        Rails.logger.debug "Receiving indexing #{druid}"
        targets = params[:subtargets]
        
        indexer = BaseIndexer.indexer_class.constantize.new
        indexer.index druid, targets
        @status = report_success
        render nothing: true, status: 200
        Rails.logger.debug "Completing indexing #{druid}"
      rescue Exception => e  
        @status = report_failure request.method_symbol, params, e
        Rails.logger.error @status
        render nothing: true, status: 202
      end
    end
    
    def destroy
      begin
        druid = remove_prefix params[:druid]
        Rails.logger.debug "Receiving deleting #{druid}"
        
        indexer = BaseIndexer.indexer_class.constantize.new
        indexer.delete druid
        @status= report_success
        render nothing: true, status: 200
        Rails.logger.debug "Completing deleting #{druid}"
      rescue Exception => e  
        @status =  report_failure request.method_symbol, params, e
        Rails.logger.error @status
        render nothing: true, status: 202
      end
    end
        
  end
end
