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

require "orion6_plugin/communication"

module Orion6Plugin
  class Command
    def execute
      # first set the header:
      command_data = generate_header

      # now comes the data:
      command_data += generate_command_data

      # now send it!
      response = Communication.communicate(get_host_address, get_tcp_port, command_data)

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
      # FIXME: add a real check here
      true
    end

    def check_response_payload(response)
      # FIXME: add a real check here
      true
    end

    def get_response_payload(response)
      # TODO: other payloads might be different
      response[8..-1]
    end

    def generate_header
      field_quantity = get_field_quantity

      header = [get_equipment_number^255] # TODO: find why this is needed
      header << get_command
      header << UNKNOWN_CONSTANT
      header << 0 # TODO: find why this is needed
      header << get_field_size
      header << field_quantity
      header << divide_by_256(field_quantity)
      header << xor(header) # TODO: find why this is needed; maybe a data check?
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

    def xor(data)
      value = 0;
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
