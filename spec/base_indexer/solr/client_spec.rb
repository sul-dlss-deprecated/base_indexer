require 'spec_helper'

describe BaseIndexer::Solr::Client do
  describe '.solr_url' do
    it 'should correctly handle urls with both trailing and leading slashes' do
      connectors=[RSolr.connect(url: 'http://localhost:8983/solr/'),RSolr.connect(url: 'http://localhost:8983/solr')]
      connectors.each do |connector|
        expect(described_class.solr_url(connector)).to eq 'http://localhost:8983/solr/update?commit=true'
      end
    end
  end

  describe '.add' do
    let(:druid) { 'tn629pk3948' }
    let(:solr_connector) {RSolr.connect url: 'http://localhost:8983/solr/'}
    after(:each) do
      VCR.use_cassette('rsolr_client_index') do
        described_class.delete(druid, solr_connector) # delete it to setup the test for next time
      end
    end
    it 'should add an item to the solr index' do
      purl_model = nil
      VCR.use_cassette('available_purl_xml') do
        purl_model =  DiscoveryIndexer::InputXml::Purlxml.new(druid).load
      end

      mods_model = nil
      VCR.use_cassette('available_mods_xml') do
        mods_model =  DiscoveryIndexer::InputXml::Modsxml.new(druid).load
      end

      mapper = DiscoveryIndexer::Mapper::GeneralMapper.new(druid, mods_model, purl_model)
      solr_doc = mapper.convert_to_solr_doc

      VCR.use_cassette('rsolr_client_index') do
        expect(described_class.doc_exists?(druid,solr_connector)).to be false # it doesn't exist yet
        expect { described_class.add(druid, solr_doc, solr_connector) }.not_to raise_error
        described_class.commit(solr_connector)
        expect(described_class.doc_exists?(druid,solr_connector)).to be true # now it exists
      end
    end
  end

  describe '.process' do
    let(:druid) { 'cb077vs7846' }
    let(:solr_connector) {RSolr.connect url: 'http://localhost:8983/solr/', allow_update: true}
    after(:each) do
      VCR.use_cassette('rsolr_update') do
        BaseIndexer::Solr::Client.delete(druid, solr_connector) # delete it to setup the test for next time
      end
    end
    it 'should update an item that exists in solr index' do
      VCR.use_cassette('rsolr_update') do
        expect(BaseIndexer::Solr::Client.doc_exists?(druid,solr_connector)).to be false # it doesn't exist yet
        expect { BaseIndexer::Solr::Client.process(druid, { id: druid, score_isi: '10', title: 'First title' }, solr_connector, 1)}.not_to raise_error  # this should add the doc
        BaseIndexer::Solr::Client.commit(solr_connector)
        expect(BaseIndexer::Solr::Client.doc_exists?(druid,solr_connector)).to be true # now it exists
        result = solr_connector.get 'select', :params => {:q => "id:\"#{druid}\""}
        expect(result['response']['docs'][0]['id']).to eq druid
        expect(result['response']['docs'][0]['title']).to eq 'First title'
        expect(result['response']['docs'][0]['score_isi']).to eq 10
        expect { BaseIndexer::Solr::Client.process(druid, { id: druid, title: 'New title' }, solr_connector, 1)}.not_to raise_error  # this should update the doc, leaving score_isi alone
        BaseIndexer::Solr::Client.commit(solr_connector)
        expect(BaseIndexer::Solr::Client.doc_exists?(druid,solr_connector)).to be true # it still exists
        result = solr_connector.get 'select', :params => {:q => "id:\"#{druid}\""}
        expect(result['response']['docs'][0]['id']).to eq druid
        expect(result['response']['docs'][0]['title']).to eq 'New title' # title changed
        expect(result['response']['docs'][0]['score_isi']).to eq 10 # but score was untouched
      end
    end
  end

  describe '.delete' do
    it 'should delete an item from solr index' do
      druid = 'dw077vs7846'
      solr_connector = RSolr.connect url: 'http://localhost:8983/solr/'
      VCR.use_cassette('rsolr_client_delete') do
        BaseIndexer::Solr::Client.add(druid, { id: druid, title: 'New title' }, solr_connector)
        BaseIndexer::Solr::Client.commit(solr_connector)
        expect(BaseIndexer::Solr::Client.doc_exists?(druid,solr_connector)).to be true # it is there
        BaseIndexer::Solr::Client.delete(druid, solr_connector)
        BaseIndexer::Solr::Client.commit(solr_connector)
        expect(BaseIndexer::Solr::Client.doc_exists?(druid,solr_connector)).to be false # it is gone
      end
    end
  end
end
