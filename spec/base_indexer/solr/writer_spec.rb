require 'spec_helper'

RSpec.describe BaseIndexer::Solr::Writer do
  let(:sw_connection) { { url: 'http://solr-core:8983/sw-prod/' } }
  let(:preview_connection) { { url: 'http://solr-core:8983/sw-preview/' } }
  let(:mix_targets) { { 'searchworks' => true, 'searchworks:preview' => false } }
  let(:index_targets) { { 'searchworks' => true } }
  let(:delete_targets) { { 'searchworks:preview' => false } }
  let(:solr_doc) { { id: '123' } }
  let(:id) { '123' }

  before do
    allow(subject).to receive(:solr_targets_configs).and_return(
      'searchworks' => sw_connection,
      'searchworks:preview' => preview_connection
    )
  end

  describe '.process' do
    it 'should create two arrays index_targets and delete_targets' do
      expect(subject).to receive(:solr_index_client).with(id, solr_doc, ['searchworks'])
      expect(subject).to receive(:solr_delete_client).with(id, ['searchworks:preview'])
      subject.process(id, solr_doc, mix_targets)
    end
    it 'should not send delete messages when there are no delete targets' do
      expect(subject).to receive(:solr_index_client).with(id, solr_doc, ['searchworks'])
      expect(BaseIndexer::Solr::Client).not_to receive(:delete)
      subject.process(id, solr_doc, index_targets)
    end
    it 'should not send index messages when there are no index targets' do
      expect(BaseIndexer::Solr::Client).not_to receive(:add)
      expect(subject).to receive(:solr_delete_client).with(id, ['searchworks:preview'])
      subject.process(id, solr_doc, delete_targets)
    end
  end

  describe '.solr_delete_client' do
    it 'should call solr client delete method for each target' do
      expect(BaseIndexer::Solr::Client).to receive(:delete).with('aa111bb222', an_instance_of(RSolr::Client))
      expect(BaseIndexer::Solr::Client).to receive(:delete).with('aa111bb222', an_instance_of(RSolr::Client))
      subject.process('aa111bb222', {}, { 'searchworks' => false, 'searchworks:preview' => false })
    end

    it 'should not call solr client delete method when there is no client for the given target' do
      expect(BaseIndexer::Solr::Client).not_to receive(:delete)
      subject.process('aa111bb222', {}, { 'blah' => false })
    end
  end

  describe '.get_connector_for_target' do
    it 'should return a connector for a target that is avaliable in config list' do
      solr_connector = subject.get_connector_for_target('searchworks')
      expect(solr_connector).to be_a(RSolr::Client)
      expect(solr_connector.uri.to_s).to eq('http://solr-core:8983/sw-prod/')

      solr_connector = subject.get_connector_for_target('searchworks:preview')
      expect(solr_connector).to be_a(RSolr::Client)
      expect(solr_connector.uri.to_s).to eq('http://solr-core:8983/sw-preview/')
    end

    it 'should return nil for a target that is not avaliable in config list' do
      solr_connector = subject.get_connector_for_target('nothing')
      expect(solr_connector).to be_nil
    end
  end
end
