require 'spec_helper'

describe BaseIndexer::ItemsController, type: :controller do
  let(:my_instance) { instance_double(BaseIndexer::MainIndexerEngine) }
  before do
    allow(BaseIndexer::MainIndexerEngine).to receive(:new).and_return(my_instance)
  end
  describe 'PATCH/PUT update' do
    it 'creates an indexing job' do
      expect(my_instance).to receive(:index).with('bb1111cc2222', 'SEARCHWORKS' => true)
      patch :update, druid: 'druid:bb1111cc2222', subtarget: 'SEARCHWORKS', use_route: :base_indexer
      expect(response.status).to eq 200
    end
    it 'when something bad happens return a 503' do
      expect(my_instance).to receive(:index).with('bb1111cc2222', 'SEARCHWORKS' => true).and_raise(StandardError)
      patch :update, druid: 'druid:bb1111cc2222', subtarget: 'SEARCHWORKS', use_route: :base_indexer
      expect(response.status).to eq 503
    end
  end
  describe 'DELETE destroy' do
    context 'with a subtarget' do
      it 'sends an "#index" with a false to the IndexerEngine' do
        expect(my_instance).to receive(:index).with('bb1111cc2222', 'SEARCHWORKS' => false)
        delete :destroy, druid: 'druid:bb1111cc2222', subtarget: 'SEARCHWORKS', use_route: :base_indexer
        expect(response.status).to eq 200
      end
    end
    context 'without a subtarget' do
      it 'sends a "#delete" to the IndexerEngine' do
        expect(my_instance).to receive(:delete).with('bb1111cc2222')
        delete :destroy, druid: 'druid:bb1111cc2222', use_route: :base_indexer
        expect(response.status).to eq 200
      end
    end
  end
end
