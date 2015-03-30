Rails.application.routes.draw do

  mount BaseIndexer::Engine => "/base_indexer"
end
