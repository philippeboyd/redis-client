# frozen_string_literal: true

require "test_helper"

class RedisClientTest < Minitest::Test
  def setup
    @redis = RedisClient.new
  end

  def test_has_version
    assert_instance_of String, RedisClient::VERSION
  end

  def test_ping
    assert_equal "PONG", @redis.call("PING")
  end

  def test_get_set
    string = "a" * 15_000
    assert_equal "OK", @redis.call("SET", "foo", string)
    assert_equal string, @redis.call("GET", "foo")
  end

  def test_pipelining
    result = @redis.pipelined do |pipeline|
      assert_nil pipeline.call("SET", "foo", "42")
      assert_equal "OK", @redis.call("SET", "foo", "21") # Not pipelined
      assert_nil pipeline.call("EXPIRE", "foo", "100")
    end
    assert_equal ["OK", 1], result
  end
end
