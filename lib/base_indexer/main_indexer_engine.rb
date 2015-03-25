require 'discovery-indexer'
module BaseIndexer
  class MainIndexerEngine
    include DiscoveryIndexer
    
    def index druid, targets
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
    
    def get_targets_hash_from_param(targets)
      targets_hash = {}
      targets.each do |target|
        targets_hash[target] = true
      end
      return targets_hash
    end
    
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
