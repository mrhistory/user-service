require 'spec_helper'
require './app/user_service'

describe 'User Service' do
  after(:all) do
    User.delete_all
  end

  it 'should return a list of users' do
    user1 = create(:user, email: 'user1@fake.com')
    user2 = create(:user, email: 'user2@fake.com')
    get '/.json'
    last_response.body.should include(user1.email)
    last_response.body.should include(user2.email)
  end

  it 'should verify a user is not logged in' do
    user = create(:user, email: 'not_logged_in@fake.com')
    expected = { :id => user.id, :logged_in => false }.to_json
    get "/logged_in/#{user.id}.json"
    last_response.body.should == expected
    user.delete
  end

  it 'should verify a user is logged in' do
    user = create(:user, logged_in: true, email: 'logged_in@fake.com')
    expected = { :id => user.id, :logged_in => true }.to_json
    get "/logged_in/#{user.id}.json"
    last_response.body.should == expected
    user.delete
  end

  it 'should return a User when a new user is created' do
    user = {
      :email => 'new_user@fake.com',
      :password => 'fakePW',
      :password_confirmation => 'fakePW',
      :organizations => [1]
    }
    post '/.json', user.to_json
    last_response.body.should include(user[:email])
    User.where(email: user[:email]).nil?.should eq(false)
  end
end