module BaseIndexer
  class ItemsController < ApplicationController
    def update
      Rails.logger.debug "Receiving indexing #{druid}"

      indexer = BaseIndexer.indexer_class.constantize.new
      indexer.index druid, { subtarget_params => true }
      head :ok
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
    end

    private

    def druid
      params.require(:druid).gsub('druid:', '') # lop off druid prefix if sent
    end

    def optional_subtarget_params
      params.permit(:subtarget)[:subtarget]
    end

    def subtarget_params
      params.require(:subtarget)
    end
  end
end
