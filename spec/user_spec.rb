require 'spec_helper'
require './app/user_service'

describe 'User Service' do
  it 'should return status 200' do
    get '/'
    expect(last_response).to be_ok
  end
end