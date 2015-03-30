require_dependency "base_indexer/application_controller"

module BaseIndexer
  class ItemsController < ApplicationController
    respond_to :json

    def new
      begin  
        druid = params[:druid]
        targets = params[:subtargets]
        
        indexer = BaseIndexer.indexer_class.constantize.new
        indexer.index druid, targets
        @status = report_success
        render status: 200
      rescue Exception => e  
        @status = report_failure request.method_symbol, params, e
        render status: 202
      end
    end
    
    def delete
      begin
        druid = params[:druid]
        indexer = BaseIndexer.indexer_class.constantize.new
        indexer.delete druid
        @status= report_success
        render status: 200
      rescue Exception => e  
        @status =  report_failure request.method_symbol, params, e
        render status: 202
      end
    end
        
    def report_failure method_symbol, params, e
      return "#{method_symbol} #{params}\n\n#{e.inspect}\n#{e.cause }\n#{e.backtrace}"
    end
    
    def report_success
      return "success"
    end
  end
end
