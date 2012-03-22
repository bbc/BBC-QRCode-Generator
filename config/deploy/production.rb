set :application, "qrcode.prototype0.net"
set :deploy_to, "/opt/#{application}"
set :rails_env, "production"
set :domain, "qrcode"

server "#{domain}", :app, :web, :primary => true
