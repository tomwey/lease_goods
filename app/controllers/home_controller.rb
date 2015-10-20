class HomeController < ApplicationController
  def api
    @routes = []
    API::Dispatch.routes.each do |route|
      next if route.route_method.blank?
      path = route.route_path
      path.sub!('(.:format)', '.json')
      path.sub!('/:version', '')
      
      r = {
        id: path.dasherize,
        method: route.route_method,
        name: path,
        params: route.route_params,
        desc: route.route_description
      }
      @routes << r
    end
    @routes.sort_by! { |a| a[:name] }
  end
  
end