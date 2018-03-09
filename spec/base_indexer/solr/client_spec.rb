require 'spec_helper'

describe BaseIndexer::Solr::Client do
  let(:druid) { 'cb077vs7846' }
  let(:solr_doc) { double('solr_doc', {}) }

  describe '.solr_url' do
    it 'should correctly handle urls with both trailing and leading slashes' do
      connectors=[RSolr.connect(url: 'http://localhost:8983/solr/'),RSolr.connect(url: 'http://localhost:8983/solr')]
      connectors.each do |connector|
        expect(described_class.solr_url(connector)).to eq 'http://localhost:8983/solr/update?commit=true'
      end
    end
  end

  describe 'delete' do
    let (:solr_connector) { double('connector', { options: { url: 'http://localhost:8983/solr/' } } ) }
    it 'should send a delete_by_id command' do
      expect(solr_connector).to receive(:delete_by_id).with(druid, {:add_attributes=>{:commitWithin=>10000}})
      BaseIndexer::Solr::Client.delete(druid, solr_connector)
    end
  end
  describe 'update' do
    let(:response) { double({}) }
    let (:solr_connector) { double('connector', { options: { url: 'http://localhost:8983/solr/', allow_update: true } } ) }
    it 'should send update_solr_doc' do
      allow(solr_connector).to receive(:get).with("select", {:params=>{:q=>"id:\"cb077vs7846\""}}).and_return(:response)
      allow(BaseIndexer::Solr::Client).to receive(:update_solr_doc).with(druid, solr_doc, solr_connector)
      expect(solr_connector).to receive(:add).with(solr_doc, :add_attributes => {:commitWithin => 10000})
      BaseIndexer::Solr::Client.add(druid, solr_doc, solr_connector)
    end
  end
  describe 'add' do
    let(:response) { double({}) }
    let (:solr_connector) { double('connector', { options: { url: 'http://localhost:8983/solr/', allow_update: true, commitWithin: '10000'} } ) }
    it 'should send an add command' do
      allow(solr_connector).to receive(:get).with("select", {:params=>{:q=>"id:\"cb077vs7846\""}}).and_return(:response)
      expect(solr_connector).to receive(:add).with(solr_doc, :add_attributes => {:commitWithin => 10000})
      BaseIndexer::Solr::Client.add(druid, solr_doc, solr_connector)
    end
  end
end
