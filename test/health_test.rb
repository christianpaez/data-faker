# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

class HealthTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_health_endpoint
    get '/health'
    assert last_response.ok?
    assert_equal 'ok', last_response.body
  end
end
