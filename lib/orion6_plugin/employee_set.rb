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

require "lib/orion6_plugin/command"

module Orion6Plugin
  class EmployeeSet < Command
    def initialize(operation_type, registration, pis_number, name, equipment_number, host_address, tcp_port = 3000)
      set_operation_type(operation_type)
      @registration = registration
      @pis_number = pis_number
      @name = name

      @equipment_number = equipment_number
      @host_address = host_address
      @tcp_port = tcp_port

      @reponse_size = 7 # just send the data and receive the ok
    end

    def set_operation_type(operation_type)
      case operation_type
      when :add
        @operation_type = 0x31
      when :edit
        @operation_type = 0x32
      when :remove
        @operation_type = 0x33
      else
        raise "Unknown employee operation type received: #{operation_type.to_s}"
      end
    end

    private
    SET_EMPLOYEE_COMMAND = 0x86
    UNKNOWN_CONSTANT = 0x72
    EMPLOYEE_FIELD_SIZE  = 0x1
    EMPLOYEE_FIELD_QUANTITY = 0x5E

    def get_command
      SET_EMPLOYEE_COMMAND
    end

    def get_unknown_constant
      UNKNOWN_CONSTANT
    end

    def get_field_size
      EMPLOYEE_FIELD_SIZE
    end

    def get_field_quantity
      EMPLOYEE_FIELD_QUANTITY
    end

    def generate_command_data
      def internal_crc_check(data)
        # crc check for the employee data:
        crc_check(data[3..88])
      end

      # TODO: find out what is the meaning of the data in the array below:
      data = [0x02, 0x00, 0x59, 0x95]

      data += get_employee_data
      data << internal_crc_check(data)
      # unknown
      data += [0x03]
      data << crc_check(data)
    end

    def get_employee_data
      data = [@operation_type]
      data += @registration.to_s.rjust(20, "0").unpack("C*")
      # This is probably the digital check byte; ignore it:
      data += "0".unpack("C*")
      data += ",".unpack("C*") # comma separating the fields
      data += @name.to_s.ljust(52, " ").unpack("C*")
      data += ",".unpack("C*") # comma separating the fields
      data += @pis_number.to_s.rjust(12, "0").unpack("C*")
      data
    end

    def get_data_from_response(payload)
      true
    end
  end
end
