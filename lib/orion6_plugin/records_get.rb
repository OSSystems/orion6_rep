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
  class RecordsGet < Command
    def initialize(record_id, equipment_number, host_address, tcp_port = 3000)
      @record_id = record_id
      @equipment_number = equipment_number
      @host_address = host_address
      @tcp_port = tcp_port
    end

    private
    GET_RECORDS_COMMAND     = 0x86
    UNKNOWN_CONSTANT        = 0x72
    RECORDS_FIELD_SIZE      = 0x01
    RECORDS_FIELD_QUANTITY  = 0x0F
    DATA_SIZE_LAST_POSITION = 11

    def get_command
      GET_RECORDS_COMMAND
    end

    def get_unknown_constant
      UNKNOWN_CONSTANT
    end

    def get_field_size
      RECORDS_FIELD_SIZE
    end

    def get_field_quantity
      RECORDS_FIELD_QUANTITY
    end

    def get_expected_response_size
      proc do |partial_data|
        if partial_data.size >= DATA_SIZE_LAST_POSITION
          data_size_array = partial_data[9..10]
          detected_size = (data_size_array[0]*256 + data_size_array[1]) + 14
          return detected_size
        else
          return DATA_SIZE_LAST_POSITION
        end
      end
    end

    def generate_command_data
      internal_data = get_record_id
      internal_data << crc_check(internal_data)
      internal_data_size = internal_data.size

      data = [0x02] # TODO: find out what this byte does
      data << divide_by_256(internal_data_size)
      data << (internal_data_size & 255)
      data << 0x99 # TODO: find out what this byte does
      data += internal_data
      data << 0x03 # TODO: find out what this byte does
      data << crc_check(data)
    end

    def get_record_id
      @record_id.to_s.rjust(9, "0").unpack("C*")
    end

    def get_data_from_response(payload)
      payload[6..-3]
    end
  end
end
