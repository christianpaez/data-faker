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

  # TODO: need test that removes :VERSION and such from constants
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
      assert !last_response.body.include?('VERSION')
    end
  end

  # need to test for subconstants - Faker::Animal click produces subconstants such as
  # Bird, Animal and those have their own methods.
  # i.e. a new list of subconstants needs to be added.
  # TODO check that there are no more than 2 levels of nested constants or this wont work

  def test_calls_constant_submodules_ok
    assert false
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
    assert last_response.body.include?('Invalid method name')
  end

  def test_gets_constant_method_bad_request
    get '/?resource=INVALID'

    assert last_response.body.include?('Invalid constant')
  end
end
