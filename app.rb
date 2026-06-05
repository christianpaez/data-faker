# frozen_string_literal: true

require 'sinatra'
require 'faker'

# TODO: add erb precompile rule

DEFAULT_RESULT_COUNT = 1
MAX_RESULT_COUNT = 1000
MIN_RESULT_COUNT = 1

get '/health' do
  'ok'
end

get '/' do
  @resource = params['resource']
  field = params['field']
  count = params['count'] || DEFAULT_RESULT_COUNT

  @constants = valid_faker_constants
  @sub_constants = valid_faker_constant_sub_constants @resource
  @methods = list_faker_methods(@resource)
  @result = call_faker_method(@resource, field, count.to_i)
  erb :index
rescue StandardError => e
  logger.error e.backtrace
  @error = e.message
  erb :index
end

def call_faker_method(resource, field, count)
  return unless resource && field

  raise 'Invalid count' unless count.is_a?(Integer) && count >= MIN_RESULT_COUNT && count <= MAX_RESULT_COUNT

  raise "Invalid constant: #{resource}" unless Faker.const_defined?(resource)

  const = Faker.const_get(resource)

  raise "Invalid method name: #{field}" unless const.respond_to?(field.to_sym)

  count.times.map { const.send(field) }
end

def list_faker_methods(resource)
  return unless resource

  Faker.const_get(resource).singleton_class.public_instance_methods(false).select do |m|
    Faker.const_get(resource).method(m).parameters.empty?
  end.sort
rescue NameError
  raise "Invalid constant: #{resource}"
end

def valid_faker_constants
  Faker.constants.select do |const|
    obj = Faker.const_get(const)
    obj.is_a?(Module) && obj.constants.any?
  end.sort
end

def valid_faker_constant_sub_constants(current_constant)
  return unless current_constant
  raise "Invalid constant: #{current_constant}" unless Faker.const_defined?(current_constant)

  faker_constant = Faker.const_get(current_constant)
  return unless faker_constant.is_a? Module

  Faker.const_get(current_constant).constants.select { |c| faker_constant.const_get(c).is_a? Module }.sort
end
