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

require "orion6_rep/multi_message_command"

module Orion6Rep
  class EmployeeQuantityGet < Command
    def initialize(equipment_number, host_address, tcp_port = 3000)
      @equipment_number = equipment_number
      @host_address = host_address
      @tcp_port = tcp_port
      @reponse_size = 9
    end

    private
    GET_EMPLOYEE_QUANTITY_COMMAND = 0x86
    UNKNOWN_CONSTANT = 0x72
    EMPLOYEE_FIELD_SIZE  = 0x1
    EMPLOYEE_FIELD_QUANTITY = 0x6
    RETURNED_RECORD_SIZE = 87

    def get_command
      GET_EMPLOYEE_QUANTITY_COMMAND
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

    def get_sleep_time
      1
    end

    def generate_command_data
      # this data is probably imutable:
      data = [0x02, 0x00, 0x01, 0x97, 0x97, 0x03]
      #      [   2,    0,    1,  151,  151,    3]
      data << crc_check(data)
      data
    end

    def get_data_from_response(payload)
      # First byte is aways 2... I don't known why...
      # The next two bytes are probably the record quantity, in big-endian.
      record_quantity = (payload[1].ord*256 + payload[2].ord)

      # The next three bytes appear to be the employee quantity, in big-endian:
      raw_data = payload[3..(3+record_quantity)]
      employee_quantity = (raw_data[0].ord << 16)+(raw_data[1].ord << 8)+ raw_data[2].ord

      # The last three bytes appear to be a CRC XOR for the data, a useless 3
      # and the XOR CRC for the whole payload
      employee_quantity
    end
  end
end
