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

# http layer

# expects root to return all faker constants

# expects - query param that
# returns faker methods on Faker::Class

# expects to invoke the faker constant
# actual method

# expects to perform the test above given multiple
# results(dunno how faker does this)

# Application code layer

# expects a method to return all faker constants
#
# another method that returns methods given some constant
#
# expects to correctly invoke method given constant
# and said method
#
# supports multiple retuns aka list of
# data
