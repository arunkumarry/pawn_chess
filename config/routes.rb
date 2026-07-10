Rails.application.routes.draw do
  resources :games, only: [ :create, :show ] do
    member do
      post :move
    end
  end
end
