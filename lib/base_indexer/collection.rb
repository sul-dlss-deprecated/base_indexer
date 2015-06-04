module BaseIndexer
  
  # It caches the collection information such as name and catkey
  class Collection
    
    # Returns the collection name from cache, otherwise will fetch it from PURL.
    #
    # @param collection_druid [String]  is the druid for a collection e.g., ab123cd4567
    # @return [Array<String>] the collection data or [] if there is no name and catkey or the object
    #   is not a collection
    def self.get_collection_info(collection_druid)
      
      collection_info = get_from_cache(collection_druid)
      if collection_info.nil?
        collection_info = get_from_purl(collection_druid)
      end
      collection_info
    end
    
    # @param [String] collection_druid is the druid for a collection e.g., ab123cd4567
    # @return [String] return the collection label from cache if available, nil otherwise
    def self.get_from_cache(collection_druid)
      Rails.cache.read(collection_druid)
    end
    
    # @param [String] collection_druid is the druid for a collection e.g., ab123cd4567
    # @return [String] return the collection label from purl if available, nil otherwise
    def self.get_from_purl(collection_druid)
      begin
        purl_model =DiscoveryIndexer::InputXml::Purlxml.new(collection_druid).load()
        unless purl_model.nil? or (purl_model.label.nil? and purl_model.catkey.nil?) or not(purl_model.is_collection)
          Rails.cache.write(collection_druid, { label: purl_model.label, ckey: purl_model.catkey }, expires_in: 1.hours)
          { label: purl_model.label, ckey: purl_model.catkey }
        end
      rescue => e
        Rails.logger.error "There is a problem in retrieving collection name and/or catkey for #{collection_druid}. #{e.inspect}\n#{e.message }\n#{e.backtrace}"
        return {}
      end
    end
  end
end