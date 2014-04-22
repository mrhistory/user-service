configure :development do
  set :host, 'localhost:9999'
  set :force_ssl, false
end

configure :test do
  set :host, 'localhost:9999'
  set :force_ssl, false
end

configure :production do
  set :host, 'user-service-dev.herokuapp.com'
  set :force_ssl, true
end