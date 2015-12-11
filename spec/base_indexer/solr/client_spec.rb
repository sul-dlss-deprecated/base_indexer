require 'spec_helper'

describe BaseIndexer::Solr::Client do
  let(:druid) { 'cb077vs7846' }
  let (:solr_doc) { double('solr_doc', {}) }
  let(:max_retries) { 10 }
  describe '.solr_url' do
    it 'should correctly handle urls with both trailing and leading slashes' do
      connectors=[RSolr.connect(url: 'http://localhost:8983/solr/'),RSolr.connect(url: 'http://localhost:8983/solr')]
      connectors.each do |connector|
        expect(described_class.solr_url(connector)).to eq 'http://localhost:8983/solr/update?commit=true'
      end
    end
  end

  describe '.process' do
    describe 'delete' do
      let (:solr_connector) { double('connector', { options: { url: 'http://localhost:8983/solr/' } } ) }
      let(:is_delete) { true }
      it 'should send a delete_by_id command' do
        expect(solr_connector).to receive(:delete_by_id).with(druid, {:add_attributes=>{:commitWithin=>10000}})
        BaseIndexer::Solr::Client.process(druid, {}, solr_connector, max_retries, is_delete)
      end
    end
    describe 'update' do
      let(:is_delete) { false }
      let(:response) { double({}) }
      let (:solr_connector) { double('connector', { options: { url: 'http://localhost:8983/solr/', allow_update: true } } ) }
      it 'should send update_solr_doc' do
        allow(solr_connector).to receive(:get).with("select", {:params=>{:q=>"id:\"cb077vs7846\""}}).and_return(:response)
        allow(BaseIndexer::Solr::Client).to receive(:update_solr_doc).with(druid, solr_doc, solr_connector)
        expect(solr_connector).to receive(:add).with(solr_doc, :add_attributes => {:commitWithin => 10000})
        BaseIndexer::Solr::Client.process(druid, solr_doc, solr_connector, max_retries, is_delete)
      end
    end
    describe 'add' do
      let(:is_delete) { false }
      let(:response) { double({}) }
      let (:solr_connector) { double('connector', { options: { url: 'http://localhost:8983/solr/', allow_update: true, commitWithin: '10000'} } ) }
      it 'should send an add command' do
        allow(solr_connector).to receive(:get).with("select", {:params=>{:q=>"id:\"cb077vs7846\""}}).and_return(:response)
        expect(solr_connector).to receive(:add).with(solr_doc, :add_attributes => {:commitWithin => 10000})
        BaseIndexer::Solr::Client.process(druid, solr_doc, solr_connector, max_retries, is_delete)
      end
    end
  end
end
