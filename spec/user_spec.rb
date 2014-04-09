require 'spec_helper'
require './app/user_service'

describe 'User Service' do
  after(:each) do
    User.delete_all
  end

  it 'should return a list of users' do
    user1 = create(:user, email: 'user1@fake.com')
    user2 = create(:user, email: 'user2@fake.com')
    get '/users/.json'
    last_response.body.should include(user1.email)
    last_response.body.should include(user2.email)
  end

  it 'should verify a user is not logged in' do
    user = create(:user, email: 'not_logged_in@fake.com')
    expected = { :id => user.id, :logged_in => false }.to_json
    get "/logged_in/#{user.id}.json"
    last_response.body.should eq(expected)
  end

  it 'should verify a user is logged in' do
    user = create(:user, logged_in: true, email: 'logged_in@fake.com')
    expected = { :id => user.id, :logged_in => true }.to_json
    get "/logged_in/#{user.id}.json"
    last_response.body.should eq(expected)
  end

  it 'should return a User when a new user is created' do
    user = {
      :email => 'new_user@fake.com',
      :password => 'fakePW',
      :password_confirmation => 'fakePW',
      :organizations => [1]
    }
    post '/users/.json', user.to_json
    last_response.body.should include(user[:email])
    User.where(email: user[:email]).exists?.should eq(true)
  end

  it 'should return an error on User creation' do
    user = {
      :email => 'new_user@fake.com',
      :password => 'fakePW',
      :password_confirmation => 'fakePW'
    }
    post '/users/.json', user.to_json
    last_response.body.should include('Organizations cannot be empty.')
    User.where(email: user[:email]).exists?.should eq(false)
  end

  it 'should return a User for /users/:id' do
    user = create(:user, email: 'existing_user@fake.com')
    get "/users/#{user.id}.json"
    last_response.body.should include(user.email)
  end

  it 'should update a User' do
    user = create(:user, email: 'updated_user@fake.com')
    put "/users/#{user.id}.json", { :first_name => 'Updated' }.to_json
    last_response.body.should include('Updated')
    User.find(user.id).first_name.should eq('Updated')
  end

  it 'should delete a User' do
    user = create(:user, email: 'deleted_user@fake.com')
    expected = { :id => user.id, :deleted => true }.to_json
    delete "/users/#{user.id}.json"
    last_response.body.should eq(expected)
    User.where(id: user.id).exists?.should eq(false)
  end

  it 'should login a user' do
    user = create(:user, email: 'login@fake.com')
    put '/login/.json', { :email => user.email, :password => 'fakePW' }.to_json
    last_response.body.should include(user.email)
    User.find(user.id).logged_in.should eq(true)
  end

  it 'should not login a user with a bad password' do
    user = create(:user, email: 'bad_login@fake.com')
    put '/login/.json', { :email => user.email, :password => 'BADfakePW' }.to_json
    last_response.body.should include('Invalid email or password.')
  end
end