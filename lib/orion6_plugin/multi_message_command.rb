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

module Orion6Plugin
  class MultiMessageCommand < Command
    def execute
      # calculate how many messages will be needed:
      messages_quantity = get_field_quantity / get_field_size
      message_remainder = get_field_quantity % get_field_size

      payload = ""

      @messages_sent = 0
      messages_quantity.times do
        command_data = generate_partial_message_header
        payload += get_and_process_message(command_data)

        # For some very obscure reason, on each received message the next
        # command must increased by the size of the received payload.
        # Go figure...
        @command += payload.size
        @messages_sent += 1
      end

      if message_remainder > 0
        command_data = generate_remainder_header(message_remainder)
        payload += get_and_process_message(command_data)
      end

      return get_data_from_response(payload)
    end

    private
    MULTI_MESSAGE_COMMAND = 151

    def get_equipment_number
      @equipment_number
    end

    def get_host_address
      @host_address
    end

    def get_tcp_port
      @tcp_port
    end

    def get_tcp_port
      @tcp_port
    end

    def generate_partial_message_header
      header = [get_equipment_number^255] # TODO: find why this is needed
      header << MULTI_MESSAGE_COMMAND
      header << 0 # TODO: find why this is needed
      header << 1 # TODO: find why this is needed
      header << get_field_size
      header << (get_command & 255) # first byte of command
      header << divide_by_256(get_command)  # second byte of command
      header << crc_check(header)
      header
    end

    def generate_remainder_header(message_remainder)
      header = [get_equipment_number^255] # TODO: find why this is needed
      header << MULTI_MESSAGE_COMMAND
      header << 0 # TODO: find why this is needed
      header << message_remainder
      header << 1 # TODO: find why this is needed
      header << (get_command & 255)
      header << divide_by_256(get_command)
      header << crc_check(header)
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
      []
    end

    def get_data_from_response(payload)
      raise "This method should be overriden by the subclass"
    end

    def first_message_sent?
      @messages_sent && @messages_sent > 0
    end

    def get_and_process_message(command_data)
      # now send it!
      response = Communication.communicate(get_host_address, get_tcp_port, command_data, get_expected_response_size, get_timeout_time, get_max_attempts)

      # check everything:
      check_response_header(response)
      check_response_payload(response)

      # and then get and process the response payload:
      get_response_payload(response)
    end
  end
end
