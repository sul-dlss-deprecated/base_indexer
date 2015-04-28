module BaseIndexer
  class AboutController < ApplicationController
  
    def index
      render :text=>'ok', :status=>200
    end
  
    def version
      
      @result={:app_name=>Rails.configuration.app_name,:rails_env=>Rails.env,:version=>Rails.configuration.app_version,:last_restart=>(File.exists?('tmp/restart.txt') ? File.new('tmp/restart.txt').mtime : "n/a"),:last_deploy=>(File.exists?('REVISION') ? File.new('REVISION').mtime : "n/a")}
      @result.update({:solr_cores=>BaseIndexer.solr_configuration_class_name.constantize.instance.get_configuration_hash})
      
      respond_to do |format|
        format.json {render :json=>@result.to_json}
        format.xml {render :json=>@result.to_xml(:root => 'status')}
        format.html {render}
      end      
      
    end
    
  end
end