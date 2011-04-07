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

require "orion6_rep/command"

module Orion6Rep
  class GetSerialNumber < Command
    def initialize(equipment_number, host_address, tcp_port = 3000)
      @equipment_number = equipment_number
      @host_address = host_address
      @tcp_port = tcp_port
      @reponse_size = RETURNED_RECORD_SIZE
    end

    private
    GET_SERIAL_NUMBER_COMMAND = 0x97
    # TODO: find what is this constant. It's the size of something, perhaps?
    UNKNOWN_CONSTANT = 0x00
    SERIAL_NUMBER_FIELD_SIZE  = 0x108
    SERIAL_NUMBER_FIELD_QUANTITY = 0x2a
    RETURNED_RECORD_SIZE = 9

    def get_command
      GET_SERIAL_NUMBER_COMMAND
    end

    def get_unknown_constant
      UNKNOWN_CONSTANT
    end

    def get_field_size
      SERIAL_NUMBER_FIELD_SIZE
    end

    def get_field_quantity
      SERIAL_NUMBER_FIELD_QUANTITY
    end

    def generate_command_data
      # No data in this command:
      []
    end

    def get_data_from_response(payload)
      convert_to_integer_as_big_endian(payload.unpack("C*")).to_s.rjust(17, "0")
    end
  end
end
