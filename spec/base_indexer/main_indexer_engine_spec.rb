require 'spec_helper'

describe BaseIndexer::MainIndexerEngine do
  before :all do
    DiscoveryIndexer::PURL_DEFAULT = 'https://purl.stanford.edu'
  end

  describe '.delete' do
    it 'should call solr_delete_from_all for delete call' do
      expect_any_instance_of(BaseIndexer::Solr::Writer).to receive(:solr_delete_from_all)
        .with('aa111aa1111', 'target1' => { 'url' => 'http://localhost:8983/solr/' }, 'target2' => { 'url' => 'http://localhost:8983/solr/' })

      BaseIndexer::MainIndexerEngine.new.delete 'aa111aa1111'
    end
  end

  describe '.read_purl' do
    it 'should read purl xml for a valid druid' do
      VCR.use_cassette('read_purl_vaild') do
        purl_model = DiscoveryIndexer::InputXml::Purlxml.new('dk605tp1619').load
        expect(purl_model.label).to eq('Walters MS 690')
      end
    end

    it 'should raise an error for not found druid' do
      VCR.use_cassette('read_purl_in_vaild') do
        expect { DiscoveryIndexer::InputXml::Purlxml.new('aa111aa1111').load }.to raise_error(DiscoveryIndexer::Errors::MissingPurlPage)
      end
    end
  end

  describe '.read_mods' do
    it 'should read mods xml for a valid druid' do
      VCR.use_cassette('read_mods_vaild') do
        mods_model = DiscoveryIndexer::InputXml::Modsxml.new('dk605tp1619').load
        expect(mods_model.sw_full_title).to eq('Walters Ms. W.690, Single leaf of a couple embracing.')
      end
    end

    it 'should raise an error for not found druid' do
      VCR.use_cassette('read_mods_in_vaild') do
        expect { DiscoveryIndexer::InputXml::Modsxml.new('aa111aa1111').load }.to raise_error(DiscoveryIndexer::Errors::MissingModsPage)
      end
    end
  end
end
