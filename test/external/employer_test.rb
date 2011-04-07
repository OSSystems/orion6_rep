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

require File.dirname(__FILE__) + '/../test_helper'

class EmployerTest < Test::Unit::TestCase
  def test_get_employer
    ip = ENV["IP"]
    t = TimeClock.new(ip, 3000, 1)

    puts "Retrieving employer from '#{ip}'..."
    payload = t.get_employer
    puts "Received: " + payload.inspect
  end

  def test_set_employer
    ip = ENV["IP"]
    t = TimeClock.new(ip, 3000, 1)

    print "Retrieve the original employer on '#{ip}'... "
    original_employer = t.get_employer
    puts "OK!"

    print "Set a new employer... "
    t.set_employer("RAZAO_SOCIAL_TEST", "LOCATION_TEST", :cnpj, "12345", "54321")
    print "OK!\nReceive the new employer data to check... "
    new_employer = t.get_employer

    print "OK!\nSet a different employer... "
    t.set_employer("RAZAO_SOCIAL", "LOCATION", :cnpj, "67890", "09876")
    print "OK!\nReceive the different employer data to check... "
    different_employer = t.get_employer
    assert_not_equal new_employer, different_employer

    print "OK!\nRestore the original employer... "
    t.set_employer(original_employer[:company_name], original_employer[:company_location], original_employer[:document_type], original_employer[:document_number], original_employer[:cei_document])
    print "OK!\nReceive the employer data to check if it is the original... "
    assert_equal original_employer, t.get_employer
    puts "OK!"
  end
end
