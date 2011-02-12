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
require 'app/models/time_clock'

class EmployeeTest < ActiveSupport::TestCase
  def setup
    reset_database
  end

  test "get employees quantity" do
    ip = ENV["IP"]
    t = TimeClock.create(:description => "Clock 1", :ip => ip, :tcp_port => 3000, :number => 1)
    assert t.valid?

    puts "Retrieving employees quantity from '#{ip}'..."
    payload = t.get_employees_quantity
    puts "Received: " + payload.inspect
  end

  test "get employees" do
    ip = ENV["IP"]
    t = TimeClock.create(:description => "Clock 1", :ip => ip, :tcp_port => 3000, :number => 1)
    assert t.valid?

    puts "Retrieving employees from '#{ip}'..."
    data = t.get_employees
    puts "Received: " + data.inspect
    data.each do |employee_data|
      assert_equal(20, employee_data[:registration].size)
      assert_equal(12, employee_data[:pis_number].size)
    end
  end
end