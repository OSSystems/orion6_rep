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
