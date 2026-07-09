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

  def test_gets_constant_public_methods_ok
    Faker::Currency.singleton_class.define_method(:test_code) {}
    Faker::Currency.singleton_class.define_method(:test_name) {}
    Faker::Currency.singleton_class.class_eval do
      protected
      define_method(:protected_test_method) {}
    end

    get '/?resource=Currency'

    assert last_response.ok?
    body = last_response.body
    assert body.include?('test_code')
    assert body.include?('test_name')
    assert !body.include?('VERSION')
    assert !body.include?('InvalidStatePassed')
    assert !body.include?('protected_test_method')
  ensure
    Faker::Currency.singleton_class.remove_method(:test_code)
    Faker::Currency.singleton_class.remove_method(:test_name)
    Faker::Currency.singleton_class.remove_method(:protected_test_method)
  end

  def test_gets_constants_without_required_parameters_ok
    Faker::Char.singleton_class.define_method(:with_keyword_parameter) { |some_parameter:| }

    get '/?resource=Char'

    assert last_response.ok?
    assert !last_response.body.include?('with_keyword_parameter')
  ensure
    Faker::Char.singleton_class.remove_method(:with_keyword_parameter)
  end

  def test_gets_constants_without_any_parameters_ok
    get '/?resource=Alphanumeric'

    assert last_response.ok?
    assert !last_response.body.include?('Alphanumeric')
  end
  
  def test_gets_subconstant_methods_without_required_parameters_ok
    Faker::Blockchain::Bitcoin.singleton_class.define_method(:with_required_parameter) { |some_parameter| }

    get '/?resource=Blockchain::Bitcoin'

    assert last_response.ok?
    assert !last_response.body.include?('with_required_parameter')
  ensure
    Faker::Blockchain::Bitcoin.singleton_class.remove_method(:with_required_parameter)
  end

  def test_gets_constants_without_required_block_ok
    Faker::Char.singleton_class.define_method(:with_block_parameter) { |&some_block| }

    get '/?resource=Char'

    assert last_response.ok?
    assert !last_response.body.include?('with_block_parameter')
  ensure
    Faker::Char.singleton_class.remove_method(:with_block_parameter)
  end

  def test_gets_constants_without_rest_parameters_ok
    Faker::Char.singleton_class.define_method(:with_rest_parameter) { |*some_block| }

    get '/?resource=Char'

    assert last_response.ok?
    assert !last_response.body.include?('with_rest_parameter')
  ensure
    Faker::Char.singleton_class.remove_method(:with_rest_parameter)
  end

  def test_gets_constant_methods_supporting_sub_constants_ok
    Faker::Creature::Animal.singleton_class.define_method(:test_code) {}
    Faker::Creature::Animal.singleton_class.define_method(:test_name) {}
    get '/?resource=Creature::Animal'

    assert last_response.ok?
    body = last_response.body
    assert body.include?('test_code')
    assert body.include?('test_name')
  ensure
    Faker::Creature::Animal.singleton_class.remove_method(:test_code)
    Faker::Creature::Animal.singleton_class.remove_method(:test_name)
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

  def test_calls_constant_method_with_count_ok
    codes = %w[code1 code2 code3 code4 code5]
    Faker::Currency.stub(:code, -> { codes.shift }) do
      get '/?resource=Currency&field=code&count=5'

      assert last_response.ok?
      assert last_response.body.include?('code1')
      assert last_response.body.include?('code2')
      assert last_response.body.include?('code3')
      assert last_response.body.include?('code4')
      assert last_response.body.include?('code5')
    end
  end

  def test_calls_constant_method_with_count_bad_request
    get '/?resource=Currency&field=code&count=INVALID'

    assert last_response.body.include?('Invalid count')
    get '/?resource=Currency&field=code&count=1001'

    assert last_response.body.include?('Invalid count')
  end
end
