require 'v1/helpers'
require 'v1/entities'

module V1
  class Root < Grape::API
    version 'v1'
    
    default_error_formatter :json
    content_type :json, 'application/json;charset=utf-8'
    format :json
    # formatter :json, Grape::Formatter::ActiveModelSerializers

    # 异常处理
    rescue_from :all do |e|
      case e
      when ActiveRecord::RecordNotFound
        Rack::Response.new(['数据不存在'], 404, {}).finish
      when Grape::Exceptions::ValidationErrors
        Rack::Response.new([{
          error: "参数不符合要求，请检查参数是否按照 API 要求传输。",
          validation_errors: e.errors
        }.to_json], 400, {}).finish
      else
        Rails.logger.error "APIv1 Error: #{e}\n#{e.backtrace.join("\n")}"
        Rack::Response.new([{ error: "API 接口异常: #{e}"}.to_json], 500, {}).finish
      end
    end
    
    before do
      header['Access-Control-Allow-Origin'] = '*'
      header['Access-Control-Request-Method'] = '*'
      header 'X-Robots-Tag', 'noindex'
    end
    
    helpers V1::APIHelpers
    
    # 分页参数
    # demo: 
    # params do
    #  use :pagination
    # end
    
    helpers do
      params :pagination do
        optional :page, type: Integer, desc: "当前页"
        optional :size, type: Integer, desc: "分页大小，默认值为：15"
      end
    end
    
    # mount V1::Welcome
    mount V1::AuthCodesAPI
    mount V1::Users
    mount V1::Tags
    mount V1::Items
    mount V1::Comments
    mount V1::Reports
    mount V1::Messages
    
    add_swagger_documentation(
      :api_version => "api/v1",
      hide_documentation_path: true,
      # mount_path: "/api/v1/swagger_doc",
      hide_format: true
    )
    
  end
end