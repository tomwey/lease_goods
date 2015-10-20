module V1
  class Welcome < Grape::API
    
    resource :a do
      desc %(简单的 API 测试接口，需要验证，便于快速测试 OAuth 以及其他 API 的基本格式是否正确) do
        detail '这是更加详细的文档描述'
      end
      params do
        requires :hi, type: String, desc: "参数一"
        optional :dddd, type: Integer, desc: "参数二"
      end
      get 'foo' do
        {
          foo: 'bar'
        }
      end
    
      desc %(Say Hi)
      get 'hi' do
        {
          msg: "你好"
        }
      end
    
    end
    
  end
end