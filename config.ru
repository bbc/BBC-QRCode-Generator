require 'rubygems'
require 'bundler'

Bundler.require

use Rack::Cache,
  :verbose => true,
  :metastore => 'file:/tmp/rack/qrcode/meta',
  :entitystore => 'file:/tmp/rack/qrcode/body'

require './webapp.rb'
run BBCQRCode 

