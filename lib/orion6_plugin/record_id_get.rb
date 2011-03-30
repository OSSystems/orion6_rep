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
  class RecordIdGet < Command
    def initialize(record_start_date_time, equipment_number, host_address, tcp_port = 3000)
      @record_start_date_time = record_start_date_time
      @equipment_number = equipment_number
      @host_address = host_address
      @tcp_port = tcp_port
      @reponse_size = 16
    end

    private
    GET_RECORD_ID_COMMAND    = 0x86
    UNKNOWN_CONSTANT         = 0x72
    RECORD_FIELD_SIZE        = 0x01
    RECORD_ID_FIELD_QUANTITY = 0x12

    def get_command
      GET_RECORD_ID_COMMAND
    end

    def get_unknown_constant
      UNKNOWN_CONSTANT
    end

    def get_field_size
      RECORD_FIELD_SIZE
    end

    def get_field_quantity
      RECORD_ID_FIELD_QUANTITY
    end

    def generate_command_data
      # TODO: find out what is the meaning of the data in the array below:
      data = [0x02, 0x00, 0x0d, 0x93]

      data += get_record_start_date_time
      # unknown
      data += [0x00, 0x03]
      data << crc_check(data)
    end

    def get_record_start_date_time
      @record_start_date_time.strftime("%d%m%Y%H%M").unpack("C*")
    end

    def get_data_from_response(payload)
      # first byte is unknown, and the next two bytes are the size of the data,
      # in big-endian:
      data_size_raw = payload.unpack("xCC")
      data_size = convert_to_integer_as_big_endian(data_size_raw)

      # minus the crc check position:
      data_size = data_size - crc_size
      payload.unpack("x4A#{data_size}")[0].to_i
    end
  end
end
