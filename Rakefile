# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

# Orion6Plugin::Application.load_tasks

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "orion6_plugin"
    gem.summary = "Plugin to manage Henry Orion 6 eletronic timeclocks"
    gem.description = "Use this plugin to manage several features of the Henry Orion 6 eletronic timeclocks, like report creation, user management, configuration etc."
    gem.authors = ["O.S. Systems Softwares Ltda."]
    gem.email = "contato@ossystems.com.br"
    gem.homepage = "http://www.ossystems.com.br/"
    gem.files = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*"]
  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end
