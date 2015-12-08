require 'spec_helper'

describe BaseIndexer::MainIndexerEngine do
  before :all do
    DiscoveryIndexer::PURL_DEFAULT = 'https://purl.stanford.edu'
  end

  describe '.index' do

  end

  describe '.targets_hash_from_param' do
    it 'should convert targets list to hash' do
      target_hash = BaseIndexer::MainIndexerEngine.new.targets_hash_from_param(%w(target1 target2))
      expect(target_hash).to eq('target1' => true, 'target2' => true)
    end
    it 'should return empty hash for empty list' do
      target_hash = BaseIndexer::MainIndexerEngine.new.targets_hash_from_param([])
      expect(target_hash).to eq({})
    end
    it 'should return empty hash for nil list' do
      target_hash = BaseIndexer::MainIndexerEngine.new.targets_hash_from_param(nil)
      expect(target_hash).to eq({})
    end
  end

  describe '.collection_data' do
    let(:collection_one) do
      double('collection', collection_info: {
               label: 'The Caroline Batchelor Map Collection',
               ckey: '10357851'
             }
            )
    end
    let(:collection_two) do
      double('collection', collection_info: {
               label: 'Richard Maxfield Collection',
               ckey: '8833854'
             }
            )
    end
    it 'should return collection name for multi druid list' do
      engine = BaseIndexer::MainIndexerEngine.new
      allow(BaseIndexer::Collection).to receive(:new).with('ct961sj2730').and_return(collection_one)
      allow(BaseIndexer::Collection).to receive(:new).with('yz499rr9528').and_return(collection_two)
      names_hash = engine.collection_data(%w(ct961sj2730 yz499rr9528))
      expect(names_hash['ct961sj2730']).to eq(label: 'The Caroline Batchelor Map Collection', ckey: '10357851')
      expect(names_hash['yz499rr9528']).to eq(label: 'Richard Maxfield Collection', ckey: '8833854')
    end

    it 'should exclude the name for item druid' do
      VCR.use_cassette('get_collection_name_for_item') do
        names_hash = BaseIndexer::MainIndexerEngine.new.collection_data(['dk605tp1619'])
        expect(names_hash).to eq({})
      end
    end

    it 'should return empty hash for empty list' do
      VCR.use_cassette('get_collection_name_for_item') do
        names_hash = BaseIndexer::MainIndexerEngine.new.collection_data([])
        expect(names_hash).to eq({})
      end
    end

    it 'should return empty hash for nil list' do
      VCR.use_cassette('get_collection_name_for_item') do
        names_hash = BaseIndexer::MainIndexerEngine.new.collection_data(nil)
        expect(names_hash).to eq({})
      end
    end
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
        purl_model = BaseIndexer::MainIndexerEngine.new.read_purl('dk605tp1619')
        expect(purl_model.label).to eq('Walters MS 690')
      end
    end

    it 'should raise an error for not found druid' do
      VCR.use_cassette('read_purl_in_vaild') do
        expect { BaseIndexer::MainIndexerEngine.new.read_purl('aa111aa1111') }.to raise_error
      end
    end
  end

  describe '.update_targets_before_write' do
    it 'returns the target_hash as it is' do
      purl_model = BaseIndexer::MainIndexerEngine.new.read_purl('dk605tp1619')
      new_target_hash = BaseIndexer::MainIndexerEngine.new.update_targets_before_write({ 'target1' => { 'url' => 'http://localhost:8983/solr/' }, 'target2' => { 'url' => 'http://localhost:8983/solr/' } }, purl_model)
      expect(new_target_hash).to eq('target1' => { 'url' => 'http://localhost:8983/solr/' }, 'target2' => { 'url' => 'http://localhost:8983/solr/' })
    end
  end

  describe '.read_mods' do
    it 'should read mods xml for a valid druid' do
      VCR.use_cassette('read_mods_vaild') do
        mods_model = BaseIndexer::MainIndexerEngine.new.read_mods('dk605tp1619')
        expect(mods_model.sw_full_title).to eq('Walters Ms. W.690, Single leaf of a couple embracing.')
      end
    end

    it 'should raise an error for not found druid' do
      VCR.use_cassette('read_mods_in_vaild') do
        expect { BaseIndexer::MainIndexerEngine.new.read_mods('aa111aa1111') }.to raise_error
      end
    end
  end
end
