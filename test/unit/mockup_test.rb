# -*- coding: utf-8 -*-
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

class MockupTest < Test::Unit::TestCase
  # load the mockup
  def setup
    load 'orion6_rep/mockup.rb'
  end

  # unload the mockup
  def teardown
    load 'orion6_rep.rb'
  end

  def test_get_set_time
    time = Time.now
    tc = TimeClock.new "0.0.0.0", 0, 1
    tc.set_time time
    assert_equal time, tc.get_time
  end

  def test_get_set_employer
    tc = TimeClock.new "0.0.0.0", 0, 1
    company_name = "Super Company"
    company_location = "FOOBAR St."
    document_type = :cnpj
    document_number = 12345678901234
    cei_number = 12345
    tc.set_employer company_name, company_location, document_type, document_number, cei_number
    assert_equal({:company_name => company_name, :company_location => company_location, :document_type => document_type, :document_number => document_number, :cei_number => cei_number}, tc.get_employer)
  end

  def test_get_set_employees
    tc = TimeClock.new "0.0.0.0", 0, 1
    assert_equal 0, tc.get_employees_quantity
    assert tc.get_employees.empty?
    assert tc.get_employees(0).empty?
    assert tc.get_employees(1).empty?
    assert tc.get_employees(1000).empty?
    tc.set_employee(:add, 1234, 12345678, "Fulano de Tal")
    assert_equal 1, tc.get_employees_quantity
    assert_equal([{:registration => 1234, :pis_number => 12345678, :name => "Fulano de Tal"}], tc.get_employees)
    tc.set_employee(:edit, 1234, 123456789, "Fulano de Tel")
    assert_equal 1, tc.get_employees_quantity
    assert_equal([{:registration => 1234, :pis_number => 123456789, :name => "Fulano de Tel"}], tc.get_employees)
    tc.set_employee(:add, 12345, 1234567, "Ciclano de Tal")
    assert_equal 2, tc.get_employees_quantity
    assert_equal([{:registration => 1234, :pis_number => 123456789, :name => "Fulano de Tel"}, {:registration => 12345, :pis_number => 1234567, :name => "Ciclano de Tal"}], tc.get_employees)
    assert_equal([{:registration => 1234, :pis_number => 123456789, :name => "Fulano de Tel"}, {:registration => 12345, :pis_number => 1234567, :name => "Ciclano de Tal"}], tc.get_employees(1000))
    tc.set_employee(:remove, 12345, 1234567, "Ciclano de Tal")
    assert_equal 1, tc.get_employees_quantity
    assert_equal([{:registration => 1234, :pis_number => 123456789, :name => "Fulano de Tel"}], tc.get_employees)
  end

  def test_get_set_ip
    tc = TimeClock.new "0.0.0.0", 0, 1
    tc.change_ip("0.0.0.1")
    assert_equal "0.0.0.1", Orion6Rep::Mockup.mock_ip
  end

  def test_get_set_ip
    tc = TimeClock.new "0.0.0.0", 0, 1
    tc.change_ip("0.0.0.1")
    assert_equal "0.0.0.1", Orion6Rep::Mockup.mock_ip
  end

  def test_get_record_id
    tc = TimeClock.new "0.0.0.0", 0, 1
    parser = load_afd_file_fixture
    tc.set_records parser
    assert_equal 6, tc.get_record_id(Time.local 2011,2,11,17,22)
    assert_equal 6, tc.get_record_id(Time.local 2011,2,11,17,23)
    assert_equal 7, tc.get_record_id(Time.local 2011,2,11,17,24)
    assert_nil tc.get_record_id(Time.local 2035,2,11,17,23)
  end

  def test_get_records
    tc = TimeClock.new "0.0.0.0", 0, 1
    parser = load_afd_file_fixture
    tc.set_records parser
    tc.set_employer "Super Company", "FOOBAR St.", :cnpj, 12345678901234, 12345
    assert_equal([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 999999999],
                 tc.get_records.records.collect{|t| t.line_id})
  end

  def test_get_records_specifing_id
    tc = TimeClock.new "0.0.0.0", 0, 1
    parser = load_afd_file_fixture
    tc.set_records parser
    tc.set_employer "Super Company", "FOOBAR St.", :cnpj, 12345678901234, 12345
    assert_equal([0, 5, 6, 7, 8, 9, 999999999],
                 tc.get_records(5).records.collect{|t| t.line_id})
  end

  private
  def load_afd_file_fixture
    parser = AfdParser.new(true)
    file = File.open("test/afd_file", "r")
    file.readlines.each_with_index do |line, index|
      parser.parse_line(line, index)
    end
    file.close
    return parser
  end
end
