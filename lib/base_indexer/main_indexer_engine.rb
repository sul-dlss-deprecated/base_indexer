require 'discovery-indexer'
module BaseIndexer
  class MainIndexerEngine
    include DiscoveryIndexer
    
    def index druid, targets
      purl_model =  read_purl(druid)
      mods_model =  read_mods(druid)
      collection_names = get_collection_names(purl_model.collection_druids)
      solr_doc = map(druid, mods_model, purl_model, collection_names)
      
      targets_hash={}
      if targets.nil? or targets.length == 0
        targets_hash = purl_model.release_tags_hash
      else
        targets_hash = get_targets_hash_from_param(targets)
      end
      
      write(druid, solr_doc, targets_hash, get_solr_targets_configs())
    end
    
    def delete druid
      solr_writer = DiscoveryIndexer::Writer::SolrWriter.new
      solr_writer.solr_delete_from_all( druid,  get_solr_targets_configs())
    end
    
    def read_purl druid
      return DiscoveryIndexer::InputXml::Purlxml.new(druid).load()
    end
    
    def read_mods druid
      return DiscoveryIndexer::InputXml::Modsxml.new(druid).load()
    end
    
    def map druid, mods_model, purl_model, collection_names
      return DiscoveryIndexer::Mapper::IndexerlMapper.new(druid, mods_model, purl_model, collection_name).map 
    end
    
    def write druid, solr_doc, targets, solr_targets_configs
      solr_writer = DiscoveryIndexer::Writer::SolrWriter.new
      solr_writer.process( druid, solr_doc, targets, solr_targets_configs)
      #DiscoveryIndexer::Writer::SolrClient.add(solr_doc, solr_connector)
    end
    
    def get_targets_hash_from_param(targets)
      targets_hash = {}
      targets.each do |target|
        targets_hash[target] = true
      end
      return targets_hash
    end
    
#    def get_targets_hash_from_release_tags release_tags
#      indexer_target_name = "Robot_Testing_Feb_5_2015"
#      return DiscoveryIndexer::Utilities::ExtractSubTargets.by_name(indexer_target_name,release_tags ) 
#    end
    
    def get_solr_targets_configs
      return BaseIndexer.solr_configuration_class.constantize.instance.get_configuration_hash
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
