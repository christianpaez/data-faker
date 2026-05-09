# frozen_string_literal: true

require 'sinatra'
require 'faker'

get '/' do
  Faker.constants.to_s
end

get '/health' do
  'ok'
end
