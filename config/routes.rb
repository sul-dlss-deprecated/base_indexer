BaseIndexer::Engine.routes.draw do
  root 'about#index'
  get 'about/version' => 'about#version'
  get 'about' => 'about#version'

  resources :items, only: [:destroy], param: :druid, default: { format: :json } do
    member do
      patch 'subtargets/:subtarget', action: :update
      put 'subtargets/:subtarget', action: :update
      delete 'subtargets/:subtarget', action: :destroy
    end
  end

  resources :collections, only: :update
end
