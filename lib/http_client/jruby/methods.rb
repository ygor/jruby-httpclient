require 'rack'

module HTTP
  class Request
    attr_accessor :body, :encoding

    def initialize(uri, params = {})
      @scheme, @host, @port, @path, query = parse_uri(uri)
      @query_params = ::Rack::Utils.parse_query(query || "")
      @params = params

      @encoding = "UTF-8"
      @headers = {}
    end

    def add_headers(headers)
      @headers.merge!(headers)
    end

    def content_type=(type)
      add_headers({'content-type' => type})
    end

    def basic_auth(username, password)
      @username = username
      @password = password
    end

    def make_native_request(client)
      request = create_native_request

      request.entity = StringEntity.new(@body) unless @body.nil?
      @headers.each { |name, value| request.add_header(name.to_s, value.to_s) }

      unless @username.nil?
        client.credentials_provider.set_credentials(AuthScope::ANY, UsernamePasswordCredentials.new(@username, @password))
      end

      HTTP::Response.new(client.execute(request), client.cookie_store.cookies)
    end

    private

    def collect_params(params)
      params.collect { |key, value| BasicNameValuePair.new(key.to_s, value.to_s) }
    end

    def create_uri(query_string = nil)
      query_string ||= URLEncodedUtils.format(collect_params(@query_params.merge @params), encoding)
      URIUtils.create_uri(@scheme, @host, @port, @path, query_string, nil)
    end

    def parse_uri(uri)
      uri = URI.parse(uri)
      [uri.scheme, uri.host, uri.port, uri.path, uri.query]
    rescue URI::InvalidURIError
      [nil, nil, nil, uri, nil]
    end
  end

  class Post < Request
    def create_native_request
      query_string = URLEncodedUtils.format(collect_params(@query_params), encoding)
      post = HttpPost.new(create_uri(query_string))
      post.entity = UrlEncodedFormEntity.new(collect_params(@params), encoding)
      post
    end
  end

  class Get < Request
    def create_native_request
      HttpGet.new(create_uri)
    end
  end

  class Head < Request
    def create_native_request
      HttpHead.new(create_uri)
    end
  end

  class Options < Request
    def create_native_request
      HttpOptions.new(create_uri)
    end
  end

  class Delete < Request
    def create_native_request
      HttpDelete.new(create_uri)
    end
  end

  class Put < Request
    def create_native_request
      query_string = URLEncodedUtils.format(collect_params(@query_params), encoding)
      put = HttpPut.new(create_uri(query_string))
      put.entity = UrlEncodedFormEntity.new(collect_params(@params), encoding)
      put
    end
  end

  private
  HttpGet = org.apache.http.client.methods.HttpGet
  HttpHead = org.apache.http.client.methods.HttpHead
  HttpOptions = org.apache.http.client.methods.HttpOptions
  HttpPost = org.apache.http.client.methods.HttpPost
  HttpDelete = org.apache.http.client.methods.HttpDelete
  HttpPut = org.apache.http.client.methods.HttpPut
  BasicNameValuePair = org.apache.http.message.BasicNameValuePair
  URIUtils = org.apache.http.client.utils.URIUtils
  URLEncodedUtils = org.apache.http.client.utils.URLEncodedUtils
  UrlEncodedFormEntity = org.apache.http.client.entity.UrlEncodedFormEntity
  AuthScope = org.apache.http.auth.AuthScope
  UsernamePasswordCredentials = org.apache.http.auth.UsernamePasswordCredentials
  StringEntity = org.apache.http.entity.StringEntity
end