Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :weather do 
    get :index
  end

  namespace :cities do
    get :autocomplete
  end
  root to: 'weather#index'
end
