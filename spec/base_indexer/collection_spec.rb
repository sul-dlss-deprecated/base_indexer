describe BaseIndexer::Collection do
    before :all do
    DiscoveryIndexer::PURL_DEFAULT='http://purl.stanford.edu/'
  end
  
  describe ".get_from_cahce" do
    it "should return collection name from the cache" do
      Rails.cache.write("aa111aa1111", "Collection 1")
      cname = BaseIndexer::Collection.get_from_cahce("aa111aa1111")
      expect(cname).to eq("Collection 1")
    end
    
    it "should return nil for the collection name that is not in the cache" do
      Rails.cache.clear
      cname=BaseIndexer::Collection.get_from_cahce("aa111aa1111")
      expect(cname).to eq(nil)
    end
  end
  
  describe ".get_from_purl" do
    it "should return a collection label from purl" do
 #     VCR.use_cassette("get_collection_name_from_purl") do
        cname=BaseIndexer::Collection.get_from_purl("ww121ss5000")
        expect(cname).to eq("Walters Manuscripts")
 #     end
    end

    it "should return nil for druid without purl" do
      VCR.use_cassette("get_collection_name_no_purl") do
        cname=BaseIndexer::Collection.get_from_purl("aa111aa1111")
        expect(cname).to eq(nil)
      end
    end
  end
  
  describe ".get_collection_name" do
    it "should return the collection name from the cache if it is available" do
      Rails.cache.write("aa111aa1111", "Collection 1")
      cname = BaseIndexer::Collection.get_collection_name("aa111aa1111")
      expect(cname).to eq("Collection 1")    
    end
    it "should return the collection name from the purl if it is not available in cache" do
      VCR.use_cassette("get_collection_name_from_purl") do
        Rails.cache.clear
        cname = BaseIndexer::Collection.get_collection_name("ww121ss5000")
        expect(cname).to eq("Walters Manuscripts")
      end
    end
  end
end