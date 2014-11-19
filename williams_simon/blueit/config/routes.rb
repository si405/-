Rails.application.routes.draw do

#  Removed this when adding custom controller for devise - devise_for :users

  devise_for :users, 
  	controllers: {sessions: 'users/sessions', :registrations => "devise/custom/registrations"}

  resources :posts do
    resources :comments
    member do
      get 'upvote'
      get 'downvote'
    end
  end

  root 'posts#index'

end
