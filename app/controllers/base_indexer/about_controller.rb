module BaseIndexer
  class AboutController < ApplicationController
    def index
      render text: 'ok', status: 200
    end

    def version
      @result = { app_name: Rails.configuration.app_name, rails_env: Rails.env, version: Rails.configuration.app_version, last_restart: (File.exist?('tmp/restart.txt') ? File.new('tmp/restart.txt').mtime : 'n/a'), last_deploy: (File.exist?('REVISION') ? File.new('REVISION').mtime : 'n/a'), revision: (File.exist?('REVISION') ? File.read('REVISION') : 'n/a') }
      @result.update(solr_cores: Settings.SOLR_TARGETS)
      @result.update(gems: Gem.loaded_specs) if request.format.html?

      respond_to do |format|
        format.json { render json: @result.to_json }
        format.xml { render json: result.to_xml(root: 'status') }
        format.html { render }
        # add the solr core names
      end
    end
  end
end
