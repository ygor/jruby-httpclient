require 'helper'

class TestBasicClientOperations < Test::Unit::TestCase
  def test_simple_get
    response = @client.get("/echo", :content => "hello")

    assert_equal("hello", response.body)
  end

  def test_simple_post
    response = @client.post("/echo", :content => "world")

    assert_equal("world", response.body)
  end

  def test_simple_delete
    response = @client.delete("/echo")

    assert_equal("delete", response.body)
  end

  def test_simple_put
    response = @client.put("/echo")

    assert_equal("put", response.body)
  end

  def test_can_get_full_url
    response = @client.get("http://localhost:8080/echo", :content => "hello")

    assert_equal("hello", response.body)
  end

  def test_can_post_full_url
    response = @client.post("http://localhost:8080/echo", :content => "hello")

    assert_equal("hello", response.body)
  end

  def test_can_delete_full_url
    response = @client.delete("http://localhost:8080/echo")

    assert_equal("delete", response.body)
  end

  def test_can_put_full_url
    response = @client.put("http://localhost:8080/echo")

    assert_equal("put", response.body)
  end

  def test_get_can_take_parameters_in_url
    response = @client.get("http://localhost:8080/echo?content=bar")

    assert_equal("bar", response.body)
  end

  def test_get_url_parameters_take_precedence_over_optional_parameters
    response = @client.get("http://localhost:8080/echo?content=bar", :content => "zed")

    assert_equal("bar", response.body)
  end

  def test_timeout
    client = HTTP::Client.new(:default_host => "http://localhost:8080", :timeout_in_seconds => 2)

    assert_raises(Timeout::Error) do
      client.get("/slow", :sleep => "30")
    end
  end

  def setup
    @client = HTTP::Client.new(:default_host => "http://localhost:8080")
  end

  def teardown
    @client.shutdown
  end
end