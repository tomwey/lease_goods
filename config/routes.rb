Rails.application.routes.draw do
  
  # get 'api' => 'home#api', as: 'api'
  
  require 'dispatch'
  mount GrapeSwaggerRails::Engine => '/apidoc'
  mount API::Dispatch => '/api'
  
end
