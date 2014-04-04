ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'factory_girl'
require 'factories'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryGirl::Syntax::Methods
end

def app
  Sinatra::Application
end