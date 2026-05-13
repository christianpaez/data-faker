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

  def test_gets_constant_method_ok
    Faker::Currency.stub(:methods, %i[test_code test_name]) do
      get '/?resource=Currency'

      assert last_response.ok?
      assert last_response.body.include?('test_code')
      assert last_response.body.include?('test_name')
    end
  end

  def test_calls_constant_provided_method
    Faker::Currency.stub(:code, 'USD') do
      get '/?resource=Currency&field=code'

      assert last_response.ok?
      assert last_response.body.include?('USD')
    end
  end

  def test_calls_constant_provided_method_bad_request
    get '/?resource=Currency&field=INVALID'
    assert last_response.bad_request?
    assert last_response.body.include?('Invalid method name')
  end
  # also test for modules namespaced outside of default
  # i need to also test for nested modules i.e. Faker::Creature::Animal.methods

  def test_gets_constant_method_bad_request
    get '/?resource=INVALID'

    assert last_response.body.include?('Invalid constant')
    assert last_response.bad_request?
  end
end
