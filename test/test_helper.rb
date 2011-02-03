ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/application', __FILE__)

require 'rubygems'
require 'active_support'
require 'action_controller'
require 'action_controller/test_case'
require 'action_view'
require 'active_record'

require 'rails/test_help'

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

class Test::Unit::TestCase
end
