BaseIndexer::Engine.routes.draw do
  root 'about#index'
  get 'about/version' => 'about#version'

  post '/items/:druid', to: 'items#new'
  delete '/items/:druid', to: 'items#destroy'
end
