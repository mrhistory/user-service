require 'sinatra'
require 'mongoid'
require 'json'
require './config/settings'
require './app/models'

Mongoid.load!('./config/mongoid.yml')

before do
  content_type :json
  ssl_whitelist = ['/calendar.ics']
  if settings.force_ssl && !request.secure? && !ssl_whitelist.include?(request.path_info)
    halt 400, "Please use SSL at https://#{settings.host}"
  end
end

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'web_service_user' and password == 'catbrowncowjumps'
end

get '/' do
  'Welcome to the User Service!'
end

get '/users/.json' do
  User.all.to_json
end

post '/users/.json' do
  user = User.new(json_params)
  if user.save
    user.safe_json
  else
    halt 500, user.errors.to_json
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
    halt 500, user.errors.to_json
  end
end

delete '/users/:id.json' do
  user = User.find(params[:id])
  if user.destroy
    { :id => user.id, :deleted => true }.to_json
  else
    halt 500, user.errors[0].to_json
  end
end

get '/users/logged_in/:id.json' do
  user = User.find(params[:id])
  { :id => user.id, :logged_in => user.logged_in ||= false }.to_json
end

put '/users/login/.json' do
  params = json_params
  user = User.authenticate(params[:email], params[:password], params[:remember_me] ||= false)
  if user.nil?
    halt 500, 'Invalid email or password.'
  elsif !user.active?
    halt 500, 'User is inactive.'
  else
    user.safe_json
  end
end

get '/users/remember_me/:token.json' do
  user = User.where(:remember_me_token => params[:token]).first
  if user.nil?
    halt 500, 'No user associated with token.'
  else
    user.safe_json
  end
end

put '/users/logout/.json' do
  user = User.find(json_params[:id])
  if user.logout!
    { :id => user.id, :logged_in => user.logged_in ||= false }.to_json
  else
    halt 500, user.errors[0].to_json
  end
end

put '/users/activate/.json' do
  user = User.where(:activation_code => json_params[:activation_code]).first
  if user.nil?
    halt 500, 'No user associated with that activation code.'
  else
    if user.activate!
      user.safe_json
    else
      halt 500, user.errors[0].to_json
    end
  end
end

post '/users/reset_password/.json' do
  params = json_params
  user = User.where(:email => params[:email]).first
  if user.nil?
    halt 500, 'No user associated with that email address.'
  else
    user.make_reset_token
    if user.save!
      { :reset_token => user.reset_token }.to_json
    else
      halt 500, user.errors[0].to_json
    end
  end
end

put '/users/reset_password/.json' do
  params = json_params
  user = User.where(:reset_token => params[:reset_token]).first
  if user.nil?
    halt 500, 'No user associated with that reset token.'
  else
    user.password = params[:password]
    user.password_confirmation = params[:password_confirmation]
    user.reset_token = nil
    user.logged_in = true
    if user.save!
      user.safe_json
    else
      halt 500, user.errors[0].to_json
    end
  end
end

private

def json_params
  JSON.parse(request.env['rack.input'].read, symbolize_names: true)
end