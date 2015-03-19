module BaseIndexer
  class Collections
    def self.get_collection_name(collection_druid)
      
      collection_name = get_from_cahce(collection_druid)
      if collection_name.nil?
        collection_name = get_from_purl(collection_druid)
      end
      collection_name
    end
    
    def self.get_from_cahce(collection_druid)
      Rails.cache.read(collection_druid)
    end
    
    def self.get_from_purl(collection_druid)
      begin
        purl_model =DiscoveryIndexer::InputXml::Purlxml.new(collection_druid).load()
        unless purl_model.nil? or purl_model.label.nil? 
          Rails.cache.write(collection_druid, purl_model.label, expires_in: 1.hours)
          purl_model.label
        end
      rescue Exception => e
        puts e
        return nil
      end
    end
  end
end