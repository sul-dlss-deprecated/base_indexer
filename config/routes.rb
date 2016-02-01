BaseIndexer::Engine.routes.draw do
  root 'about#index'
  get 'about/version' => 'about#version'
  get 'about' => 'about#version'

  resources :items, only: [:update, :destroy]
  resources :collections, only: :update
end
