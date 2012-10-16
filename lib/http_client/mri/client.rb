module HTTP
  class Client
    def initialize(options)
      @default_host = options[:default_host]
      @timeout_in_seconds = options[:timeout_in_seconds]
      @uri = URI.parse(@default_host)
    end

    def get(url, params = {})
      execute HTTP::Get.new(url, params)
    end

    def post(url, params = {})
      execute HTTP::Post.new(url, params)
    end

    def delete(url, params = {})
      execute HTTP::Delete.new(url, params)
    end

    def put(url, params = {})
      execute HTTP::Put.new(url, params)
    end

    def head(url, params = {})
      execute HTTP::Head.new(url, params)
    end

    def execute(req)
      req.execute_native_request(self)
    end

    def execute_request(requested_host, requested_port, req)
      host = requested_host || @uri.host
      port = requested_port || @uri.port
      req['Cookie'] = @cookie unless @cookie.nil?

      Net::HTTP.new(host, port).start do |http|
        http.read_timeout = @timeout_in_seconds || 30
        response = http.request(req)

        if response['location']
          redirect_uri = URI.parse(response['location'])
          return execute_request(redirect_uri.host, redirect_uri.port,  Net::HTTP::Get.new("#{redirect_uri.path}?#{redirect_uri.query}"))
        end

        @cookie = response['set-cookie']

        response
      end
    end

    def shutdown; end
  end
end