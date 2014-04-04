require 'sinatra'
require 'mongoid'
require './config/settings'
require './app/models'

Mongoid.load!('./config/mongoid.yml')

get '/' do
  'It runs!'
end

post '/' do
  User.create(params).to_json
end

get '/logged_in/:id' do
  user = User.find(params[:id])
  { :id => user.id, :logged_in => user.logged_in ||= false }.to_json
end