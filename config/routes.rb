Rails.application.routes.draw do
  
  devise_for :items, ActiveAdmin::Devise.config
  devise_for :admins, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # get 'api' => 'home#api', as: 'api'
  
  require 'dispatch'
  mount GrapeSwaggerRails::Engine => '/apidoc'
  mount API::Dispatch => '/api'
  
end
