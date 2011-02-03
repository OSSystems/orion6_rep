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

class TimeClockTest < ActiveSupport::TestCase
  def setup
    reset_database
  end

  test "create TimeClock" do
    t = TimeClock.create(:description => "Clock 1", :ip => "192.168.0.1", :tcp_port => 3000, :number => 1)
    assert t.valid?
    assert !t.new_record?
  end

  test "try to create TimeClock without description" do
    t = TimeClock.create(:description => nil, :ip => "192.168.0.1", :tcp_port => 3000, :number => 1)
    assert_equal "Description can't be blank", t.errors.full_messages.join(", ")
    assert t.invalid?
    assert t.new_record?
  end

  test "try to create TimeClock without IP" do
    t = TimeClock.create(:description => "Clock 1", :ip => nil, :tcp_port => 3000, :number => 1)
    assert_equal "Ip can't be blank", t.errors.full_messages.join(", ")
    assert t.invalid?
    assert t.new_record?
  end

  test "try to create TimeClock without TCP port" do
    t = TimeClock.create(:description => "Clock 1", :ip => "192.168.0.1", :tcp_port => nil, :number => 1)
    assert_equal "Tcp port can't be blank", t.errors.full_messages.join(", ")
    assert t.invalid?
    assert t.new_record?
  end

  test "try to create TimeClock without number" do
    t = TimeClock.create(:description => "Clock 1", :ip => "192.168.0.1", :tcp_port => 3000, :number => nil)
    assert_equal "Number can't be blank", t.errors.full_messages.join(", ")
    assert t.invalid?
    assert t.new_record?
  end
end
