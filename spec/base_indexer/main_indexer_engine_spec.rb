describe BaseIndexer::MainIndexerEngine do
  
  before :all do
    DiscoveryIndexer::PURL_DEFAULT='http://purl.stanford.edu/'
  end
  
  describe ".index" do
    pending
  end
  
  describe ".get_targets_hash_from_param" do
    it "should convert targets list to hash" do
      target_hash = BaseIndexer::MainIndexerEngine.new.get_targets_hash_from_param(["target1","target2"])
      expect(target_hash).to eq({"target1"=>true, "target2"=>true})
    end
    it "should return empty hash for empty list" do
      target_hash = BaseIndexer::MainIndexerEngine.new.get_targets_hash_from_param([])
      expect(target_hash).to eq({})
    end
    it "should return empty hash for nil list" do
      target_hash = BaseIndexer::MainIndexerEngine.new.get_targets_hash_from_param(nil)
      expect(target_hash).to eq({})
    end
  end
  
  describe ".get_collection_names" do
    it "should return collection name for one druid list" do
      VCR.use_cassette("get_collection_name") do
        names_hash = BaseIndexer::MainIndexerEngine.new.get_collection_names(["ct961sj2730"])
        expect(names_hash.include?("ct961sj2730")).to be true
        expect(names_hash["ct961sj2730"]).to eq("The Caroline Batchelor Map Collection")
      end
    end
 
    it "should return collection name for multi druid list" do
      VCR.use_cassette("get_collection_name_two_collections") do
        names_hash = BaseIndexer::MainIndexerEngine.new.get_collection_names(["ct961sj2730","yz499rr9528"])
        expect(names_hash["ct961sj2730"]).to eq("The Caroline Batchelor Map Collection")
        expect(names_hash["yz499rr9528"]).to eq("[Richard Maxfield Collection]")
      end
    end
     
    it "should exclude the name for item druid" do
      VCR.use_cassette("get_collection_name_for_item") do
        names_hash = BaseIndexer::MainIndexerEngine.new.get_collection_names(["dk605tp1619"])
        expect(names_hash).to eq({})
      end
    end
    
    it "should return empty hash for empty list" do
      VCR.use_cassette("get_collection_name_for_item") do
        names_hash = BaseIndexer::MainIndexerEngine.new.get_collection_names([])
        expect(names_hash).to eq({})
      end
    end
    
    it "should return empty hash for nil list" do
      VCR.use_cassette("get_collection_name_for_item") do
        names_hash = BaseIndexer::MainIndexerEngine.new.get_collection_names(nil)
        expect(names_hash).to eq({})
      end
    end  
  end
  
  describe ".delete" do
    it "should call solr_delete_from_all for delete call" do
      BaseIndexer::SolrConfigurationFromFile.instance.read("spec/fixtures/solr.yml")
      expect_any_instance_of(DiscoveryIndexer::Writer::SolrWriter).to receive(:solr_delete_from_all)
        .with("aa111aa1111",{"target1"=>{"url"=>"http://localhost:8983/solr/"}, "target2"=>{"url"=>"http://localhost:8983/solr/"}})
        
      BaseIndexer::MainIndexerEngine.new.delete "aa111aa1111"
    end
  end
  
  describe ".read_purl" do
    it "should read purl xml for a valid druid" do
      VCR.use_cassette("read_purl_vaild") do
        purl_model = BaseIndexer::MainIndexerEngine.new.read_purl("dk605tp1619")
        expect(purl_model.label).to eq("Walters MS 690")
      end
    end
    
    it "should raise an error for not found druid" do
      VCR.use_cassette("read_purl_in_vaild") do
        expect{BaseIndexer::MainIndexerEngine.new.read_purl("aa111aa1111")}.to raise_error
      end      
    end
    
  end
  
  describe ".read_mods" do
    it "should read mods xml for a valid druid" do
      VCR.use_cassette("read_mods_vaild") do
        mods_model = BaseIndexer::MainIndexerEngine.new.read_mods("dk605tp1619")
        expect(mods_model.sw_full_title).to eq("Walters Ms. W.690, Single leaf of a couple embracing.")
      end
    end
    
    it "should raise an error for not found druid" do
      VCR.use_cassette("read_mods_in_vaild") do
        expect{BaseIndexer::MainIndexerEngine.new.read_mods("aa111aa1111")}.to raise_error
      end      
    end
    
  end

end