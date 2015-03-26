require 'discovery-indexer'
module BaseIndexer
  
  # It is responsible for performing the basic indexing steps, it includes reading
  # the input from PURL server, getting collection names, mapping it to solr doc hash, 
  # and write it to SOLR core . It can also delete the object from all the registered 
  # 
  # @example Index with target list
  #   indexer = BaseIndexer::MainIndexerEngine.new
  #   indexer.index "ab123cd456", ["searchworks","revs"]
  #
  # @example Index from release_tags
  #   indexer = BaseIndexer::MainIndexerEngine.new
  #   indexer.index "ab123cd456"
  #
  # @example Delete item from all solr cores
  #   indexer = BaseIndexer::MainIndexerEngine.new
  #   indexer.delete "ab123cd456"
  class MainIndexerEngine
    include DiscoveryIndexer
    
    # It is the main indexing function
    # 
    # @param druid [String] is the druid for an object e.g., ab123cd4567
    # @param targets [Array] is an array with the targets list to index towards, 
    #   if it is nil, the method will read the target list from release_tags
    #
    # @raise it will raise erros if there is any problems happen in any level
    def index druid, targets=nil
      # Read input mods and purl
      purl_model =  read_purl(druid)
      mods_model =  read_mods(druid)
      collection_names = get_collection_names(purl_model.collection_druids)
      
      # Map the input to solr_doc
      solr_doc =  BaseIndexer.mapper_class_name.constantize.new(druid, mods_model, purl_model, collection_names).map
      
      # Get target list
      targets_hash={}
      if targets.nil? or targets.length == 0
        targets_hash = purl_model.release_tags_hash
      else
        targets_hash = get_targets_hash_from_param(targets)
      end
      
      # Get SOLR configuration and write
      solr_targets_configs = BaseIndexer.solr_configuration_class_name.constantize.instance.get_configuration_hash
      BaseIndexer.solr_writer_class_name.constantize.new.process( druid, solr_doc, targets_hash, solr_targets_configs)
    end
    
    # It deletes an item defined by druid from all registered solr core
    # @param druid [String] is the druid for an object e.g., ab123cd4567
    def delete druid
      solr_targets_configs = BaseIndexer.solr_configuration_class_name.constantize.instance.get_configuration_hash
      BaseIndexer.solr_writer_class_name.constantize.new.solr_delete_from_all( druid,  solr_targets_configs)
    end
    
    def read_purl druid
      return DiscoveryIndexer::InputXml::Purlxml.new(druid).load()
    end
    
    def read_mods druid
      return DiscoveryIndexer::InputXml::Modsxml.new(druid).load()
    end
    
    # It converts targets array to targets hash
    # @param targets [Array] a  list of specfic targets
    # @return [Hash] a hash of targets with true value
    # @example convert target list
    #   get_targets_hash_from_param( ["searchworks","revs"] )
    #   {"searchworks"=>true, "revs"=>true}
    def get_targets_hash_from_param(targets)
      targets_hash = {}
      targets.each do |target|
        targets_hash[target] = true
      end
      return targets_hash
    end
    
    # It converts collection_druids list to a hash with names. If the druid doesn't
    # have a collection name, it will be excluded from the hash
    # @param collection_druids [Array] a list of druids 
    #   !["ab123cd4567", "ef123gh4567"]
    # @return [Hash] a hash for collection druid and its name 
    #   !{"ab123cd4567"=>"Collection 1", "ef123gh4567"=>"Collection 2"}
    def get_collection_names collection_druids
      collection_names = {}
      
      unless collection_druids.nil? then
        collection_druids.each do |cdruid|
          cname = BaseIndexer::Collection.get_collection_name(cdruid)
          collection_names[cdruid] = cname unless cname.nil? 
        end
      end
      collection_names
    end
    
  end
end
