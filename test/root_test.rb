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

  def test_gets_constant_methods_ok
    fake_methods = %i[test_code test_name]
    Faker::Currency.stub(:methods, fake_methods) do
      get '/?resource=Currency'

      assert last_response.ok?
      body = last_response.body
      assert body.include?('test_code')
      assert body.include?('test_name')
      assert !body.include?('VERSION')
    end
  end

  def test_gets_constant_methods_supporting_sub_constants_ok
    # TODO: we need to make sure that resource can be a subconstant such as Creature::Animal
    # and displays methods.
    assert false
  end

  def test_calls_constant_submodules_ok
    Faker::Creature.stub(:constants, %w[Subconstant1 Subconstant2 Subconstant3]) do
      get '/?resource=Creature'

      assert last_response.ok?
      assert last_response.body.include?('Subconstant1')
      assert last_response.body.include?('Subconstant2')
      assert last_response.body.include?('Subconstant3')
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
    assert last_response.body.include?('Invalid method name')
  end

  def test_gets_constant_method_bad_request
    get '/?resource=INVALID'

    assert last_response.body.include?('Invalid constant')
  end
end
