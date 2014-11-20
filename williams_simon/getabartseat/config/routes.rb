Rails.application.routes.draw do
  
  resources :bartstations

  resources :bartroutes

  get '/seed_stations' => 'bartstations#seed_bart_stations'

  get '/unseed_stations' => 'bartstations#unseed_bart_stations'

  get '/seed_bart_routes' => 'bartroutes#seed_bart_routes'

  get '/unseed_bart_routes' => 'bartroutes#unseed_bart_routes'

  root 'bartstations#index'

end
