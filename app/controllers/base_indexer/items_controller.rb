require_dependency 'base_indexer/application_controller'

module BaseIndexer
  class ItemsController < ApplicationController
    def update
      Rails.logger.debug "Receiving indexing #{druid}"

      indexer = BaseIndexer.indexer_class.constantize.new
      indexer.index druid, { subtarget_params => true }
      head :ok
      Rails.logger.debug "Completing indexing #{druid}"
    rescue StandardError => e
      Rails.logger.error report_failure request.method_symbol, params, e
      head :internal_server_error
    end

    def destroy
      Rails.logger.debug "Receiving deleting #{druid}"
      indexer = BaseIndexer.indexer_class.constantize.new
      # If no subtarget is defined, delete from everywhere
      if optional_subtarget_params.nil?
        indexer.delete druid
      else
        ##
        # Only delete from specified subtarget
        indexer.index druid, { subtarget_params => false }
      end
      head :ok
      Rails.logger.debug "Completing deleting #{druid}"
    rescue StandardError => e
      Rails.logger.error report_failure request.method_symbol, params, e
      head :internal_server_error
    end

    private

    def druid
      remove_prefix params.require(:druid)
    end

    def optional_subtarget_params
      params.permit(:subtarget)[:subtarget]
    end

    def subtarget_params
      params.require(:subtarget)
    end
  end
end
