Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # Defines the root path route ("/")
  # root "posts#index"

  post 'inbound', to: 'text_sms#inbound'
  post 'outbound', to: 'text_sms#outbound'

  # Return 405 for any non-POST requests to these endpoints
  match 'inbound', to: 'text_sms#request_not_found', via: :all
  match 'outbound', to: 'text_sms#request_not_found', via: :all
end
