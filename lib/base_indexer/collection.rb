module BaseIndexer
  
  # It caches the collection information such as name
  class Collection
    
    # Returns the collection name from cache, otherwise will fetch it from PURL.
    #
    # @param collection_druid [String]  is the druid for a collection e.g., ab123cd4567
    # @return [String] the collection name or nil if there is no name or the object 
    #   is not a collection
    def self.get_collection_name(collection_druid)
      
      collection_name = get_from_cahce(collection_druid)
      if collection_name.nil?
        collection_name = get_from_purl(collection_druid)
      end
      collection_name
    end
    
    # @param [String] collection_druid is the druid for a collection e.g., ab123cd4567
    # @return [String] return the collection label from cache if available, nil otherwise
    def self.get_from_cahce(collection_druid)
      Rails.cache.read(collection_druid)
    end
    
    # @param [String] collection_druid is the druid for a collection e.g., ab123cd4567
    # @return [String] return the collection label from purl if available, nil otherwise
    def self.get_from_purl(collection_druid)
      begin
        purl_model =DiscoveryIndexer::InputXml::Purlxml.new(collection_druid).load()
        unless purl_model.nil? or purl_model.label.nil? or not(purl_model.is_collection)
          Rails.cache.write(collection_druid, purl_model.label, expires_in: 1.hours)
          purl_model.label
        end
      rescue => e
        Rails.logger.error "There is a problem in retrieving collection name for #{collection_druid}. #{e.inspect}\n#{e.message }\n#{e.backtrace}"
        return nil
      end
    end
  end
end