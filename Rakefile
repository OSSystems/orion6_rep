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

require 'rake'
require 'rake/testtask'
require 'bundler'
Bundler::GemHelper.install_tasks

desc 'Default: run unit tests.'
task :default => :test

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/unit/**/*_test.rb'
end

namespace :test do
  desc "This task runs tests with a real Orion6 Time Clock, checking things like setting/getting data, retrieving reports etc. Use IP=xxx.xxx.xxx.xxx to specify the clock to be used in th test. Be careful with this option, it may cause data loss in the clock."
  Rake::TestTask.new(:externals) do |t|
    t.libs << "test"
    t.pattern = 'test/external/**/*_test.rb'
  end
  Rake::Task["externals"].comment = "Test communication with a real Orion6 Time Clock - MAY CAUSE DATA LOSS! - Use 'IP=xxx.xxx.xxx.xxx' to specify the clock to be used in th test."
end
