module HTTP
  class Request
    def initialize(url, params = {})
      @requested_uri = url
      @params = params
      @headers = {}
    end

    def basic_auth(username, password)
      @username = username
      @password = password
    end

    def add_headers(headers)
      @headers = headers
    end

    def content_type=(content_type)
      @content_type = content_type
    end

    def body=(body)
      @body = body
    end

    def execute_native_request(client)
      host, port, req = create_request
      req.basic_auth(@username, @password)

      @headers.each {|name, value| req[name.to_s] = value.to_s}
      req.content_type = @content_type unless @content_type.nil?
      req.body = @body unless @body.nil?

      HTTP::Response.new(client.execute_request(host, port, req))
    end

    private

    def parse_uri
      request_uri = URI.parse(@requested_uri)

      host = request_uri.host
      port = request_uri.port
      path = request_uri.path
      query = request_uri.query

      [host, port, path, query]
    end

    def create_uri(path, query = '')
      "#{path}?#{query}#{'&' unless @params.empty?}#{to_query_string(@params)}"
    end

    def to_query_string(params_as_hash)
      params_as_hash.map { |name, value| "#{URI.encode(name.to_s)}=#{URI.encode(value.to_s)}" }.join("&")
    end
  end

  class Get < Request
    def create_request
      host, port, path, query = parse_uri
      get = Net::HTTP::Get.new(create_uri(path, query))
      [host, port, get]
    end
  end
  
  class Head < Request
    def create_request
      host, port, path, query = parse_uri
      head = Net::HTTP::Head.new(create_uri(path, query))
      [host, port, head]
    end
  end
  
  class Options < Request
    def create_request
      host, port, path, query = parse_uri
      options = Net::HTTP::Options.new(create_uri(path, query))
      [host, port, options]
    end
  end

  class Patch < Request
    def create_request
      host, port, path, query = parse_uri
      patch = Net::HTTP::Patch.new(create_uri(path, query))
      [host, port, patch]
    end
  end

  class Post < Request
    def create_request
      host, port, path, query = parse_uri
      post = Net::HTTP::Post.new(path + ("?#{query}" unless query == ''))
      post.set_form_data(@params)
      [host, port, post]
    end
  end

  class Put < Request
    def create_request
      host, port, path, query = parse_uri
      put = Net::HTTP::Put.new(path + ("?#{query}" unless query == ''))
      put.set_form_data(@params)      
      [host, port, put]
    end
  end

  class Delete < Request
    def create_request
      host, port, path, query = parse_uri
      delete = Net::HTTP::Delete.new(create_uri(path, query))
      [host, port, delete]
    end
  end
end