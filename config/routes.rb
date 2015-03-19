BaseIndexer::Engine.routes.draw do
  get '/items/:druid', to: 'items#new'
  delete '/items/:druid', to: 'items#destroy'
end
