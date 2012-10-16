require 'uri'
module HTTP
  DefaultHttpClient = org.apache.http.impl.client.DefaultHttpClient
  BasicResponseHandler = org.apache.http.impl.client.BasicResponseHandler
  SocketTimeoutException = java.net.SocketTimeoutException

  class Client
    def initialize(options = {})
      @client = HTTP::ClientConfiguration.new(options).build_http_client
    end

    def get(params, options = {})
      execute Get.new(params, options)
    end
    
    def head(params, options = {})
      execute Head.new(params, options)
    end
    
    def options(params, options = {})
      execute Options.new(params, options)
    end

    def post(params, options = {})
      execute Post.new(params, options)
    end

    def delete(path, options = {})
      execute Delete.new(path, options)
    end

    def put(path, options = {})
      execute Put.new(path, options)
    end

    def execute(request)
      request.make_native_request(@client)
    rescue SocketTimeoutException => e
      raise Timeout::Error, e.message
    end

    def shutdown
      @client.connection_manager.shutdown
    end
  end
end