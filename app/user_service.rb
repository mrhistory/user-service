require 'sinatra'
require 'mongoid'
require 'json'
require './config/settings'
require './app/models'

Mongoid.load!('./config/mongoid.yml')

get '/.json' do
  User.all.to_json
end

post '/.json' do
  params = JSON.parse(request.env["rack.input"].read)
  user = User.new(params)
  if user.save
    user.to_json(:except => [:password_hash, :password_salt])
  else
    user.errors.to_json
  end
end

get '/logged_in/:id.json' do
  user = User.find(params[:id])
  { :id => user.id, :logged_in => user.logged_in ||= false }.to_json
end