Rails.application.routes.draw do
  
  root 'home#index'
  
  devise_for :admins, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # get 'api' => 'home#api', as: 'api'
  
  require 'dispatch'
  mount GrapeSwaggerRails::Engine => '/apidoc'
  mount API::Dispatch => '/api'
  
end
