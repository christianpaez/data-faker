# frozen_string_literal: true

require 'byebug'
require 'minitest/autorun'
require 'minitest/mock'
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
      assert !body.include?('InvalidStatePassed')
    end
  end

  # TODO: need test to filter out constants without
  # at least one method with no arguments.
  # example Char
  #
  # TODO: same as above but with subconstants
  #
  # TODO: same as above but at method level
  # i.e. remove methods that have required parameters
  # from response, example Time.between

  def test_gets_constant_methods_without_required_parameters_ok
    Faker::Time.singleton_class.define_method(:with_keyword_parameter) { |some_parameter:| }

    get '/?resource=Time'

    assert last_response.ok?
    assert !last_response.body.include?('with_keyword_parameter')
  end

  def test_gets_constant_methods_supporting_sub_constants_ok
    fake_methods = %i[test_code test_name]
    Faker::Creature::Animal.stub(:methods, fake_methods) do
      get '/?resource=Creature::Animal'

      assert last_response.ok?
      body = last_response.body
      assert body.include?('test_code')
      assert body.include?('test_name')
    end
  end

  def test_gets_only_module_subconstants_ok
    fake_subconstant_object = %w[a b c] # Theather::Letters example
    Faker::Theater.const_set('Letters', fake_subconstant_object)

    get '/?resource=Theater'

    assert last_response.ok?
    assert !last_response.body.include?('Letters')
  ensure
    # I did not find a better way
    # to do this but whatever
    Faker::Theater.send(:remove_const, :Letters)
  end

  def test_calls_constant_submodules_ok
    Faker::Creature.const_set(:Subconstant1, Module.new)
    Faker::Creature.const_set(:Subconstant2, Module.new)
    Faker::Creature.const_set(:Subconstant3, Module.new)

    get '/?resource=Creature'

    assert last_response.ok?
    assert last_response.body.include?('Subconstant1')
    assert last_response.body.include?('Subconstant2')
    assert last_response.body.include?('Subconstant3')
  ensure
    Faker::Creature.send(:remove_const, :Subconstant1)
    Faker::Creature.send(:remove_const, :Subconstant2)
    Faker::Creature.send(:remove_const, :Subconstant3)
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
