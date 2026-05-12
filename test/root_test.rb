# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require 'faker'
require_relative '../app'

class RootTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root_endpoint
    get '/'
    assert last_response.ok?
    assert last_response.body.include?('Creature')
    assert last_response.body.include?('Currency')
  end

  def test_gets_contant_method_ok
    get '/?constant=Currency'
    Faker::Currency.stub(:methods, %i[test_code test_name]) do
      get '/?constant=Currency'

      puts last_response.body
      assert last_response.ok?
      assert last_response.body.include?('test_code')
      assert last_response.body.include?('test_name')
    end
  end

  # needs test for method execution itself i.e. Faker::Currency.code -> "USD"

  # also test for modules namespaced outside of default
  # i need to also test for nested modules i.e. Faker::Creature::Animal.methods

  def test_gets_contant_method_bad_request
    get '/?constant=INVALID'

    assert last_response.body.include?('Invalid constant')
    assert last_response.bad_request?
  end
end
