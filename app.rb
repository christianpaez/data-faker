# frozen_string_literal: true

require 'sinatra'
require 'faker'

# TODO: add erb precompile rule

get '/health' do
  'ok'
end

get '/' do
  @resource = params['resource']
  field = params['field']

  @constants = valid_faker_constants
  @sub_constants = valid_faker_constant_sub_constants @resource
  @methods = list_faker_methods(@resource)
  @result = call_faker_method(@resource, field)

  erb :index
rescue StandardError => e
  @error = e.message + '' + e.backtrace.first
  erb :index
end

def call_faker_method(resource, field)
  return unless resource && field

  raise "Invalid constant: #{resource}" unless Faker.const_defined?(resource)

  const = Faker.const_get(resource)

  raise "Invalid method name: #{field}" unless const.respond_to?(field.to_sym)

  const.send(field)
end

def list_faker_methods(resource)
  return unless resource

  Faker.const_get(resource).methods(false).map { |m| "#{m} " }.sort
rescue NameError
  raise "Invalid constant: #{resource}"
end

def valid_faker_constants
  Faker.constants.select do |const|
    obj = Faker.const_get(const)
    obj.is_a?(Module)
  end.sort
end

def valid_faker_constant_sub_constants(current_constant)
  raise "Invalid constant: #{current_constant}" unless Faker.const_defined?(current_constant)

  faker_constant = Faker.const_get(current_constant)
  return unless faker_constant.is_a? Module

  Faker.const_get(current_constant).constants.select { |c| faker_constant.const_get(c).is_a? Module }.sort
end
