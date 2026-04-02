# frozen_string_literal: true

require 'sinatra'
require 'faker'

get '/' do
  'hola'
end

get '/health' do
  'ok'
end
