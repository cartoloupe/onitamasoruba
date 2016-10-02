Rails.application.routes.draw do
  root to: 'a#m'
  get '/a/welcome/:id', to: 'a#welcome'
  post 'a/welcome_move'
  put 'a/welcome_move'

end
