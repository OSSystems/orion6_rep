require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Runs test:units, test:functionals, test:integration together'
task :test do
  errors = %w(test:units test:functionals test:integration).collect do |task|
    begin
      Rake::Task[task].invoke
      nil
    rescue => e
      task
    end
  end.compact
  abort "Errors running #{errors * ', '}!" if errors.any?
end

namespace :test do
  Rake::TestTask.new(:units) do |t|
    t.libs << 'test'
    t.pattern = 'test/unit/**/*_test.rb'
  end

  Rake::TestTask.new(:functionals) do |t|
    t.libs << "test"
    t.pattern = 'test/functional/**/*_test.rb'
  end

  Rake::TestTask.new(:integration) do |t|
    t.libs << "test"
    t.pattern = 'test/integration/**/*_test.rb'
  end
end

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
