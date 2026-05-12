# frozen_string_literal: true

require 'sinatra'
require 'faker'
require 'byebug'

get '/' do
  if params['constant']
    begin
      Faker.const_get(params['constant']).methods(false).map(&:to_s)
    rescue NameError
      status 400
      'Invalid constant'
    end

  else
    Faker.constants.to_s
  end
end

get '/health' do
  'ok'
end
