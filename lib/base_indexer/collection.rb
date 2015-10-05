module BaseIndexer

  # It caches the collection information such as name and catkey
  class Collection

    def initialize(collection_druid)
      @collection_druid = collection_druid
    end

    # Returns the collection name from cache, otherwise will fetch it from PURL.
    #
    # @param collection_druid [String]  is the druid for a collection e.g., ab123cd4567
    # @return [Array<String>] the collection data or [] if there is no name and catkey or the object
    #   is not a collection
    def collection_info
      from_cache || from_purl || {}
    end

    private

    # @param [String] collection_druid is the druid for a collection e.g., ab123cd4567
    # @return [String] return the collection label from cache if available, nil otherwise
    def from_cache
      Rails.cache.read(@collection_druid)
    end

    # @param [String] collection_druid is the druid for a collection e.g., ab123cd4567
    # @return [String] return the collection label from purl if available, nil otherwise
    def from_purl
      return nil unless purl_model
      return nil unless purl_model.is_collection
      return nil unless purl_model.label && purl_model.catkey
      purl_data = { label: purl_model.label, ckey: purl_model.catkey }
      Rails.cache.write(@collection_druid, purl_data, expires_in: 1.hours)
      purl_data
    end

    def purl_model
      DiscoveryIndexer::InputXml::Purlxml.new(@collection_druid).load
    end
  end
end
