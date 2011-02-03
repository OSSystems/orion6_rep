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

require 'rails/test_help'

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

require File.expand_path('../../lib/generators/orion6/templates/migration.rb', __FILE__)

class Test::Unit::TestCase
  class << self
    def migrated?
      @migrated ||= false
    end

    def set_migrated
      @migrated = true
    end
  end

  def reset_database
    unless self.class.migrated?
      ActiveRecord::Schema.define(:version => 1) do
        CreateTimeClockTable.up
      end
      self.class.set_migrated
    end
  end
end
