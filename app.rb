# frozen_string_literal: true

require 'sinatra'
require 'faker'

get '/health' do
  'ok'
end
get '/' do
  resource = params['resource']
  field = params['field']

  if resource && field
    call_faker_method(resource, field)
  elsif resource
    list_faker_methods(resource)
  else
    Faker.constants.sort.to_s
  end
end

def call_faker_method(resource, field)
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
  Faker.const_get(resource).methods(false).map { |m| "#{m} " }.sort
rescue NameError
  status 400
  'Invalid constant'
end
