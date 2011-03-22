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

require "lib/orion6_plugin/clock_time/get"
require "lib/orion6_plugin/clock_time/set"
require "lib/orion6_plugin/employer_get"
require "lib/orion6_plugin/employer_set"
require "lib/orion6_plugin/employee_get"
require "lib/orion6_plugin/employee_quantity_get"
require "lib/orion6_plugin/employee_set"
require "lib/orion6_plugin/detect_reps"
require "lib/orion6_plugin/change_ip"

module Orion6Plugin
  module Orion6
    class << self
      def detect_reps
        command = Orion6Plugin::DetectReps.new
        command.execute
        response = command.pool
        return response
      end
    end

    def get_time
      command = Orion6Plugin::ClockTime::Get.new(self.number, self.ip, self.tcp_port)
      response = command.execute
      return response
    end

    def set_time(time, start_dst = nil, end_dst = nil)
      command = Orion6Plugin::ClockTime::Set.new(time, start_dst, end_dst, self.number, self.ip, self.tcp_port)
      response = command.execute
      return response
    end

    def get_employer
      command = Orion6Plugin::EmployerGet.new(self.number, self.ip, self.tcp_port)
      response = command.execute
      return response
    end

    def set_employer(employer_name, employer_location, document_type, document_number, cei_number)
      command = Orion6Plugin::EmployerSet.new(employer_name, employer_location, document_type, document_number, cei_number, self.number, self.ip, self.tcp_port)
      response = command.execute
      return response
    end

    def get_employees_quantity
      command = Orion6Plugin::EmployeeQuantityGet.new(self.number, self.ip, self.tcp_port)
      response = command.execute
      return response
    end

    def get_employees(quantity = nil)
      quantity = get_employees_quantity if quantity.nil?
      command = Orion6Plugin::EmployeeGet.new(quantity, self.number, self.ip, self.tcp_port)
      response = command.execute
      return response
    end

    def set_employee(operation_type, registration, pis_number, name)
      command = Orion6Plugin::EmployeeSet.new(operation_type, registration, pis_number, name, self.number, self.ip, self.tcp_port)
      response = command.execute
      return response
    end

    def change_ip(new_ip, interface = nil, rep_data = nil)
      if interface.nil? or rep_data.nil?
        data = get_data_from_detection(self.ip)
        interface = data.first if interface.nil?
        rep_data = data.last if rep_data.nil?
      end

      command = Orion6Plugin::ChangeIp.new(interface, new_ip, rep_data)
      response = command.execute
      return new_ip if response
    end

    private
    def get_data_from_detection(ip)
      response_data = Orion6Plugin::Orion6.detect_reps
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
