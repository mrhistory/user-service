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

before do
  content_type :json
  ssl_whitelist = ['/calendar.ics']
  if settings.force_ssl && !request.secure? && !ssl_whitelist.include?(request.path_info)
    halt json_status 400, "Please use SSL at https://#{settings.host}"
  end
end