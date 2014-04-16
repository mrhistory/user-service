require 'sinatra'
require 'mongoid'
require 'json'
require './config/settings'
require './app/models'

Mongoid.load!('./config/mongoid.yml')

get '/users/.json' do
  User.all.to_json
end

post '/users/.json' do
  user = User.new(json_params)
  if user.save
    user.safe_json
  else
    user.errors.to_json
  end
end

get '/users/:id.json' do
  User.find(params[:id]).safe_json
end

put '/users/:id.json' do
  user = User.find(params[:id])
  if user.update_attributes!(json_params)
    user.safe_json
  else
    user.errors.to_json
  end
end

delete '/users/:id.json' do
  user = User.find(params[:id])
  if user.destroy
    { :id => user.id, :deleted => true }.to_json
  else
    user.errors.to_json
  end
end

get '/logged_in/:id.json' do
  user = User.find(params[:id])
  { :id => user.id, :logged_in => user.logged_in ||= false }.to_json
end

put '/login/.json' do
  params = json_params
  user = User.authenticate(params['email'], params['password'])
  if user.nil?
    { :error => 'Invalid email or password.' }.to_json
  else
    user.logged_in = true
    if user.save!
      user.safe_json
    else
      user.errors.to_json
    end
  end
end

private

def json_params
  JSON.parse(request.env['rack.input'].read)
end