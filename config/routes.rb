Rails.application.routes.draw do
  resources :rooms

  devise_for :users

  resources :users do
    get :dashboard, on: :collection
  end

  authenticated :user do
    root to: "users#dashboard", as: :authenticated_user_root
  end

  root "pages#home"
end
