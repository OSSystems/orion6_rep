# Controle de Horas - Sistema para gestão de horas trabalhadas
# Copyright (C) 2009  O.S. Systems Softwares Ltda.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Rua Clóvis Gularte Candiota 132, Pelotas-RS, Brasil.
# e-mail: contato@ossystems.com.br

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

  desc "This task runs tests with a real Orion6 Time Clock, checking things like setting/getting data, retrieving reports etc. Use IP=xxx.xxx.xxx.xxx to specify the clock to be used in th test. Be careful with this option, it may cause data loss in the clock."
  Rake::TestTask.new(:external) do |t|
    t.libs << "test"
    t.pattern = 'test/external/**/*_test.rb'
  end
  Rake::Task["external"].comment = "Test communication with a real Orion6 Time Clock - MAY CAUSE DATA LOSS! - Use 'IP=xxx.xxx.xxx.xxx' to specify the clock to be used in th test."
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
