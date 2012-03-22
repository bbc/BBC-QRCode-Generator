require 'rubygems'
require 'bundler'
Bundler.require

if ENV['RACK_ENV'] == 'production'
  use Rack::Cache,
    :verbose => true,
    :metastore => 'file:/tmp/rack/qrcode/meta',
    :entitystore => 'file:/tmp/rack/qrcode/body',
    :default_ttl => 86400
end

require './webapp.rb'
run BBCQRCode

