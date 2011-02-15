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

require "orion6_plugin/clock_time/get"
require "orion6_plugin/clock_time/set"
require "orion6_plugin/employer_get"
require "orion6_plugin/employer_set"
require "orion6_plugin/employee_get"
require "orion6_plugin/employee_quantity_get"
require "orion6_plugin/employee_set"

module Orion6Plugin
  module Orion6
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
  end
end
