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

require "lib/orion6_plugin/communication"

module Orion6Plugin
  class Command
    def execute
      # first set the header:
      command_data = generate_header

      # now comes the data:
      command_data += generate_command_data

      # now send it!
      response = Communication.communicate(get_host_address, get_tcp_port, command_data, get_expected_response_size, get_timeout_time, get_max_attempts)

      # check everything:
      check_response_header(response)
      check_response_payload(response)

      # and then get and process the response payload:
      payload = get_response_payload(response)
      return get_data_from_response(payload)
    end

    private
    # TODO: find what is this constant. It's the size of something, perhaps?
    UNKNOWN_CONSTANT = 113

    HEADER_SIZE = 8
    @reponse_size = 0

    def get_timeout_time
      3
    end

    def get_max_attempts
      3
    end

    def get_expected_response_size
      HEADER_SIZE + @reponse_size
    end

    def get_unknown_constant
      UNKNOWN_CONSTANT
    end

    def get_equipment_number
      @equipment_number
    end

    def get_host_address
      @host_address
    end

    def get_tcp_port
      @tcp_port
    end

    def check_response_header(response)
      crc_check(response[0..6]) == response[7]
    end

    def check_response_payload(response)
      crc_check(response[8..-2]) == response[-1]
    end

    def get_response_payload(response)
      # TODO: other payloads might be different
      response[8..-2]
    end

    def generate_header
      field_quantity = get_field_quantity

      header = [get_equipment_number^255] # TODO: find why this is needed
      header << get_command
      header << get_unknown_constant
      header << 0 # TODO: find why this is needed
      header << get_field_size
      header << field_quantity
      header << divide_by_256(field_quantity)
      header << crc_check(header) # TODO: find why this is needed; maybe a data check?
      header
    end

    def get_command
      raise "This method should be overriden by the subclass"
    end

    def get_field_size
      raise "This method should be overriden by the subclass"
    end

    def get_field_quantity
      raise "This method should be overriden by the subclass"
    end

    def generate_command_data
      raise "This method should be overriden by the subclass"
    end

    def get_data_from_response(payload)
      raise "This method should be overriden by the subclass"
    end

    def crc_check(data)
      xor(data)
    end

    def xor(data)
      value = 0;
      data = data.unpack("C*") if data.is_a?(String)
      data.each do |integer|
        value ^= integer
      end
      value
    end

    def divide_by_256(value)
      return (value >> 8 & 255)
    end
  end
end
