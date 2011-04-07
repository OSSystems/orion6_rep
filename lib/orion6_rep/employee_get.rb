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
  class EmployeeGet < Command
    def initialize(employees_number, equipment_number, host_address, tcp_port = 3000)
      @employees_number = employees_number
      @equipment_number = equipment_number
      @host_address = host_address
      @tcp_port = tcp_port
      @reponse_size = (employees_number*RETURNED_RECORD_SIZE)+4+3
    end

    private
    GET_EMPLOYEE_COMMAND = 0x86
    EMPLOYEE_FIELD_SIZE  = 0x1
    EMPLOYEE_FIELD_QUANTITY = 0x9
    # TODO: find what is this constant. It's the size of something, perhaps?
    UNKNOWN_CONSTANT = 0x72
    RETURNED_RECORD_SIZE = 87

    def get_command
      GET_EMPLOYEE_COMMAND
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
        crc_check(data[3..6])
      end

      # this data can change:
      data = [0x02, 0x00, 0x04, 0x98, 0x00, 0x01]
      data << @employees_number
      data << internal_crc_check(data)
      data << 0x03
      data << crc_check(data)
    end

    def get_data_from_response(payload)
      # first byte is aways 2... I don't known why...
      # The next two bytes are probably the record quantity, in big-endian.
      record_quantity = (payload[1]*256 + payload[2])

      # byte #4 it's the beggining of the data:
      start_offset = 4

      # the end of the data is the size plus the start minus two, since the REP
      # send the CRC at the end of the data and array starts at zero. The last
      # two bytes appear to be the end data marker and a useless 3.
      end_offset = record_quantity + start_offset - crc_size - 1

      raw_data = payload[start_offset..end_offset]
      slices = slice_raw_data(raw_data)

      data = []
      slices.each do |slice|
        # the fields are separated by a comma, and the registration comes with a
        # extra number at the end, so drop them:
        registration, name, pis_number = slice.unpack("A20x2A52xA12")
        data << {:name => name.to_s.strip, :registration => registration, :pis_number => pis_number}
      end
      data
    end

    def slice_raw_data(raw_data)
      slices = []
      index = 0
      while index < raw_data.size
        slice_start = index
        slice_end = slice_start + RETURNED_RECORD_SIZE - 1
        slices << raw_data[slice_start..slice_end]
        index = slice_end + 1
      end
      slices
    end
  end
end
