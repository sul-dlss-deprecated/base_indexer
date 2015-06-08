require 'spec_helper'

describe BaseIndexer::Collection do
    before :all do
    DiscoveryIndexer::PURL_DEFAULT='http://purl.stanford.edu/'
  end
  
  describe ".get_from_cache" do
    it "should return collection name and ckey from the cache" do
      Rails.cache.write("aa111aa1111", {:label => "Collection 1", :ckey=>"123456789"})
      cname = BaseIndexer::Collection.get_from_cache("aa111aa1111")
      expect(cname).to eq({:label => "Collection 1", :ckey=>"123456789"})
    end
    
    it "should return nil for the collection name and ckey that is not in the cache" do
      Rails.cache.clear
      cname=BaseIndexer::Collection.get_from_cache("aa111aa1111")
      expect(cname).to eq(nil)
    end
  end
  
  describe ".get_from_purl" do
    it "should return a collection label from purl" do
      VCR.use_cassette("get_collection_name_from_purl") do
        cname=BaseIndexer::Collection.get_from_purl("ww121ss5000")
        expect(cname).to eq({:label=>"Walters Manuscripts", :ckey=>nil})
      end
    end

    it "should return nil for druid without purl" do
      VCR.use_cassette("get_collection_name_no_purl") do
        cname=BaseIndexer::Collection.get_from_purl("aa111aa1111")
        expect(cname).to eq({})
      end
    end
  end
  
  describe ".get_collection_info" do
    it "should return the collection name from the cache if it is available" do
      Rails.cache.write("aa111aa1111", {:label => "Collection 1", :ckey=>"123456789"})
      cname = BaseIndexer::Collection.get_collection_info("aa111aa1111")
      expect(cname).to eq({:label => "Collection 1", :ckey=>"123456789"})
    end
    it "should return the collection name from the purl if it is not available in cache" do
      VCR.use_cassette("get_collection_name_from_purl") do
        Rails.cache.clear
        cname = BaseIndexer::Collection.get_collection_info("ww121ss5000")
        expect(cname).to eq({:label=>"Walters Manuscripts", :ckey=>nil})
      end
    end
  end
end