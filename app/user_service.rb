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
  begin
    User.all.to_json
  rescue Exception => e
    halt 500, e.message
  end
end

post '/users/.json' do
  begin
    user = User.new(json_params)
    if user.save
      user.safe_json
    else
      halt 500, user.errors[:base]
    end
  rescue Exception => e
    halt 500, e.message
  end
end

get '/users/:id.json' do
  begin
    user = User.find(params[:id])
    if user.nil?
      raise Exception, 'User not found.'
    else
      user.safe_json
    end
  rescue Exception => e
    halt 500, e.message
  end
end

put '/users/:id.json' do
  begin
    user = User.find(params[:id])
    if user.update_attributes!(json_params)
      user.safe_json
    else
      halt 500, user.errors[:base]
    end
  rescue Exception => e
    halt 500, e.message
  end
end

delete '/users/:id.json' do
  begin
    user = User.find(params[:id])
    if user.destroy
      { :id => user.id, :deleted => true }.to_json
    else
      halt 500, user.errors[:base]
    end
  rescue Exception => e
    halt 500, e.message
  end
end

get '/users/logged_in/:id.json' do
  begin
    user = User.find(params[:id])
    { :id => user.id, :logged_in => user.logged_in ||= false }.to_json
  rescue Exception => e
    halt 500, e.message
  end
end

put '/users/login/.json' do
  begin
    params = json_params
    user = User.authenticate(params[:email], params[:password], params[:remember_me] ||= false)
    if user.nil?
      raise Exception, 'Invalid email or password.'
    elsif !user.active?
      raise Exception, 'User is inactive.'
    else
      user.safe_json
    end
  rescue Exception => e
    halt 500, e.message
  end
end

get '/users/remember_me/:token.json' do
  begin
    user = User.where(:remember_me_token => params[:token]).first
    if user.nil?
      raise Exception, 'No user associated with token.'
    else
      user.safe_json
    end
  rescue Exception => e
    halt 500, e.message
  end
end

put '/users/logout/.json' do
  begin
    user = User.find(json_params[:id])
    if user.logout!
      { :id => user.id, :logged_in => user.logged_in ||= false }.to_json
    else
      halt 500, user.errors[:base]
    end
  rescue Exception => e
    halt 500, e.message
  end
end

put '/users/activate/.json' do
  begin
    user = User.where(:activation_code => json_params[:activation_code]).first
    if user.nil?
      raise Exception, 'No user associated with that activation code.'
    else
      if user.activate!
        user.safe_json
      else
        halt 500, user.errors[:base]
      end
    end
  rescue Exception => e
    halt 500, e.message
  end
end

post '/users/reset_password/.json' do
  begin
    params = json_params
    user = User.where(:email => params[:email]).first
    if user.nil?
      raise Exception, 'No user associated with that email address.'
    else
      user.make_reset_token
      if user.save!
        { :reset_token => user.reset_token }.to_json
      else
        halt 500, user.errors[:base]
      end
    end
  rescue Exception => e
    halt 500, e.message
  end
end

put '/users/reset_password/.json' do
  begin
    params = json_params
    user = User.where(:reset_token => params[:reset_token]).first
    if user.nil?
      raise Exception, 'No user associated with that reset token.'
    else
      user.password = params[:password]
      user.password_confirmation = params[:password_confirmation]
      user.reset_token = nil
      user.logged_in = true
      if user.save!
        user.safe_json
      else
        halt 500, user.errors[:base]
      end
    end
  rescue Exception => e
    halt 500, e.message
  end
end

private

def json_params
  JSON.parse(request.env['rack.input'].read, symbolize_names: true)
end