set :application, "qrcode-staging.prototype0.net"
set :deploy_to, "/opt/#{application}"
set :rails_env, "staging"
set :domain, "qrcode"

server "#{domain}", :app, :web, :primary => true
