require 'rubygems'
require 'bundler'

Bundler.setup(:default, :development)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'confrere'

RSpec.configure do |config|
  config.color = true
end