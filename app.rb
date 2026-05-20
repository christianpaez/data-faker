# frozen_string_literal: true

require 'sinatra'
require 'faker'

get '/health' do
  'ok'
end
get '/' do
  resource = params['resource']
  field = params['field']

  @methods ||= list_faker_methods(resource)
  @constants ||= Faker.constants.sort
  @result ||= call_faker_method(resource, field)

  erb :index
end

def call_faker_method(resource, field)
  return unless resource && field

  unless Faker.const_defined?(resource)
    status 400
    return 'Invalid constant'
  end

  const = Faker.const_get(resource)

  unless const.respond_to?(field.to_sym)
    status 400
    return 'Invalid method name'
  end

  const.send(field)
end

def list_faker_methods(resource)
  return unless resource

  Faker.const_get(resource).methods(false).map { |m| "#{m} " }.sort
rescue NameError
  status 400
  'Invalid constant'
end
