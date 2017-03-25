Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope :api do
    resources :books, except: :put
    resources :authors, except: :put
    resources :publishers, except: :put
    resources :users, except: :put

    get '/search/:text', to: 'search#index'
  end

  root to: 'books#index'
end
