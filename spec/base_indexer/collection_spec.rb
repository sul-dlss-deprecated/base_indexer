require 'spec_helper'

describe BaseIndexer::Collection do
  let(:druid) { 'abc123' }
  let(:subject) { described_class.new(druid) }
  let(:purl_model) { double('purl-model', label: nil, catkey: nil, is_collection: nil) }
  after do
    Rails.cache.clear
  end
  describe 'erroneous druid' do
    it 'should return {} upon error' do
      # recode once error captured
      # expect(subject.collection_info).to eq({})
    end
  end
  describe 'correct druid' do
    before do
      allow(subject).to receive_messages(purl_model: purl_model)
    end
    describe 'collection_info' do
      describe 'from cache' do
        let(:druid) { 'xyz987' }
        it 'should return valid information from cache' do
          purl_data = { abc123: '123' }
          Rails.cache.write(druid, purl_data, expires_in: 1.hours)
          expect(subject.collection_info).to eq purl_data
        end
      end
      describe 'from purl' do
        describe 'cache written correctly' do
        end
        describe 'correct data returned' do
          let(:druid) { 'lmn567' }
          it 'should return valid information from purl when both catkey and label are available' do
            purl_data = { label: 'Collection label', ckey: '12345678' }
            allow(purl_model).to receive_messages(
              label: 'Collection label',
              catkey: '12345678',
              is_collection: true
            )
            expect(subject.collection_info).to eq purl_data
          end
          it 'should return nil when both no catkey and no label in the purl metadata' do
            allow(purl_model).to receive_messages(
              is_collection: true
            )
            expect(subject.collection_info).to eq({})
          end
          it 'should return nil when no catkey but there is a label in the purl metadata' do
            allow(purl_model).to receive_messages(
              label: 'Collection label',
              is_collection: true
            )
            expect(subject.collection_info).to eq({})
          end
          it 'should return nil when catkey but no label in the purl metadata' do
            allow(purl_model).to receive_messages(
              catkey: '12345678',
              is_collection: true
            )
            expect(subject.collection_info).to eq({})
          end
          it 'should return nil when it is not a collection' do
            allow(purl_model).to receive_messages(
              label: 'Collection label',
              catkey: '12345678',
              is_collection: false
            )
            expect(subject.collection_info).to eq({})
          end
        end
      end
    end
  end
end
