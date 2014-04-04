# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'shotgun', :server => 'thin', :port => '3000' do
  watch %r{^(app|config|lib|views)/.*\.rb}
  watch 'config.ru'
end

guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
  watch %r{^(app|config|lib|views)/.*\.rb}
end

