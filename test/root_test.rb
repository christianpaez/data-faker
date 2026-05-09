# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

class RootTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # expects root to return all faker constants
  def test_root_endpoint
    get '/'
    assert last_response.ok?
    assert last_response.body.include?('Creature')
    assert last_response.body.include?('Currency')
  end

  def test_gets_contant_method_ok
    get '/?constant=Currency'
    # mock Faker::Currency.name to return whatever
    assert last_response.ok?
    assert last_response.body.include?
  end

  # i need to also test for nested modules i.e. Faker::Creature::Animal.methods

  def test_gets_contant_method_bad_request
    get '/?constant=INVALID'

    assert last_response.bad_request?
  end
end
