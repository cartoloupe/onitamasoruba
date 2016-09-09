Rails.application.routes.draw do
  get 'a/welcome'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'a#welcome'
end
