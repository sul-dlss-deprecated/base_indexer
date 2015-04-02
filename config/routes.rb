BaseIndexer::Engine.routes.draw do
  post '/items/:druid', to: 'items#new'
  delete '/items/:druid', to: 'items#destroy'
end
