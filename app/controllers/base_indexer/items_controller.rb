require_dependency "base_indexer/application_controller"

module BaseIndexer
  class ItemsController < ApplicationController
    respond_to :json

    def new
      begin  
        druid = params[:druid]
        Rails.logger.debug "Receiving indexing #{druid}"
        targets = params[:subtargets]
        
        indexer = BaseIndexer.indexer_class.constantize.new
        indexer.index druid, targets
        @status = report_success
        render status: 200
        Rails.logger.debug "Completing indexing #{druid}"
      rescue Exception => e  
        @status = report_failure request.method_symbol, params, e
        Rails.logger.error @status
        render status: 202
      end
    end
    
    def destroy
      begin
        druid = params[:druid]
        Rails.logger.debug "Receiving deleting #{druid}"
        
        indexer = BaseIndexer.indexer_class.constantize.new
        indexer.delete druid
        @status= report_success
        render status: 200
        Rails.logger.debug "Completing deleting #{druid}"
      rescue Exception => e  
        @status =  report_failure request.method_symbol, params, e
        Rails.logger.error @status
        render status: 202
      end
    end
        
    def report_failure method_symbol, params, e
      return "#{method_symbol} #{params}\n\n#{e.inspect}\n#{e.message}\n#{e.backtrace}"
    end
    
    def report_success
      return "success"
    end
  end
end
