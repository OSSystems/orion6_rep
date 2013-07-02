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

require "orion6_rep/clock_time/get"
require "orion6_rep/clock_time/set"
require "orion6_rep/employer_get"
require "orion6_rep/employer_set"
require "orion6_rep/employee_get"
require "orion6_rep/employee_quantity_get"
require "orion6_rep/employee_set"
require "orion6_rep/get_serial_number"
require "orion6_rep/record_id_get"
require "orion6_rep/records_get"
require "orion6_rep/detect_reps"
require "orion6_rep/change_ip"
require "afd_parser"

module Orion6Rep
  class << self
    def included(base)
      return if base.included_modules.include?(InstanceMethods)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end
  end

  module ClassMethods
    def detect_reps
      command = Orion6Rep::DetectReps.new
      command.execute
      runtime = Time.now
      previous_response = nil
      response = {}
      while runtime + 5 > Time.now do
        response = command.pool
        sleep(0.2) if previous_response == response
        previous_response = response
      end
      return response
    end
  end

  module InstanceMethods
    def get_time
      command = Orion6Rep::ClockTime::Get.new(self.number, self.ip, self.tcp_port)
      response = command.execute
      on_communication_success(__method__.to_sym) if respond_to?(:on_communication_success)
      return response
    end

    def set_time(time, start_dst = nil, end_dst = nil)
      command = Orion6Rep::ClockTime::Set.new(time, start_dst, end_dst, self.number, self.ip, self.tcp_port)
      response = command.execute
      on_communication_success(__method__.to_sym) if respond_to?(:on_communication_success)
      return response
    end

    def get_employer
      command = Orion6Rep::EmployerGet.new(self.number, self.ip, self.tcp_port)
      response = command.execute
      on_communication_success(__method__.to_sym) if respond_to?(:on_communication_success)
      return response
    end

    def set_employer(employer_name, employer_location, document_type, document_number, cei_number)
      command = Orion6Rep::EmployerSet.new(employer_name, employer_location, document_type, document_number, cei_number, self.number, self.ip, self.tcp_port)
      response = command.execute
      on_communication_success(__method__.to_sym) if respond_to?(:on_communication_success)
      return response
    end

    def get_employees_quantity
      command = Orion6Rep::EmployeeQuantityGet.new(self.number, self.ip, self.tcp_port)
      response = command.execute
      on_communication_success(__method__.to_sym) if respond_to?(:on_communication_success)
      return response
    end

    def get_employees(quantity = nil)
      employees_quantity = quantity.nil? ? get_employees_quantity : quantity
      employees = []
      call_id = 1
      while employees_quantity > 0
        # 11 is the max number of employees retrieved in one call
        call_quantity = employees_quantity > 11 ? 11 : employees_quantity
        command = Orion6Rep::EmployeeGet.new(call_id, call_quantity, self.number, self.ip, self.tcp_port)
        employees += command.execute
        employees_quantity -= call_quantity
        call_id += call_quantity
      end
      on_communication_success(__method__.to_sym) if respond_to?(:on_communication_success)
      return employees
    end

    def set_employee(operation_type, registration, pis_number, name)
      command = Orion6Rep::EmployeeSet.new(operation_type, registration, pis_number, name, self.number, self.ip, self.tcp_port)
      response = command.execute
      on_communication_success(__method__.to_sym) if respond_to?(:on_communication_success)
      return response
    end

    def change_ip(new_ip, interface = nil, rep_data = nil)
      if interface.nil? or rep_data.nil?
        data = get_data_from_detection(self.ip)
        interface = data.first if interface.nil?
        rep_data = data.last if rep_data.nil?
      end
      if interface.nil? || rep_data.nil?
        raise "The specified IP address is not an Orion6 REP"
      end
      command = Orion6Rep::ChangeIp.new(interface, new_ip, rep_data)
      response = command.execute
      if response
        on_communication_success(__method__.to_sym) if respond_to?(:on_communication_success)
        return new_ip
      end
    end

    def get_serial_number
      command = Orion6Rep::GetSerialNumber.new(self.number, self.ip, self.tcp_port)
      response = command.execute
      on_communication_success(__method__.to_sym) if respond_to?(:on_communication_success)
      return response
    end

    def get_record_id(datetime)
      command = Orion6Rep::RecordIdGet.new(datetime, self.number, self.ip, self.tcp_port)
      response = command.execute
      on_communication_success(__method__.to_sym) if respond_to?(:on_communication_success)
      return response
    end

    def get_records(first_id = nil)
      if first_id.nil?
        first_id = 1 # get all the records
      end

      id = first_id
      parser = AfdParser.new(false)
      records = []
      while !id.nil?
        command = Orion6Rep::RecordsGet.new(id, self.number, self.ip, self.tcp_port)
        data = command.execute
        record = nil
        while data.size > 0
          record = parser.parse_line(data, id)
          size = record.class.size
          data.slice!(0..(size-1))
          records << record
          id += 1
        end

        id = record.nil? ? nil : (record.line_id + 1)
      end

      afd_start_date = parser.first_creation_date
      afd_end_date = parser.last_creation_date
      employer = get_employer
      serial_number = get_serial_number
      parser.create_header(employer[:document_type], employer[:document_number],
                           employer[:cei_document], employer[:company_name],
                           serial_number, afd_start_date, afd_end_date, Time.now)
      parser.create_trailer
      return parser
    end

    private
    def get_data_from_detection(ip)
      response_data = self.class.detect_reps
      response_data.each do |collected_interface, interface_data|
        interface_data.each do |collected_ip, data|
          if collected_ip == self.ip
            interface = collected_interface
            rep_data = data[:rep_data]
            return [interface, rep_data]
          end
        end
      end
      return []
    end
  end
end
