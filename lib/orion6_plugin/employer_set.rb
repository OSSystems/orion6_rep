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

require "orion6_plugin/multi_message_command"

module Orion6Plugin
  class EmployerSet < Command
    def initialize(employer_name, employer_location, document_type, document_number, cei_number, equipment_number, host_address, tcp_port = 3000)
      @employer_name = employer_name
      @employer_location = employer_location
      @document_type = document_type
      @document_number = document_number
      @cei_number = cei_number

      @equipment_number = equipment_number
      @host_address = host_address
      @tcp_port = tcp_port
      @reponse_size = 0
    end

    private
    SET_EMPLOYER_COMMAND = 143
    EMPLOYER_FIELD_SIZE  = 1
    EMPLOYER_FIELD_QUANTITY = 263

    def get_command
      SET_EMPLOYER_COMMAND
    end

    def get_field_size
      EMPLOYER_FIELD_SIZE
    end

    def get_field_quantity
      EMPLOYER_FIELD_QUANTITY
    end

    # Here is how the data goes to the REP:
    # 0 - 1
    # 1 - Document type:
    #   1: CNPJ
    #   2: CPF
    # 2-15 - Document number (in hexadecimal long)
    # 16-27 - CEI Document (in hexadecimal long)
    # 28-177 - Company name
    # 178-263 - Company location
    def generate_command_data
      data = [1] # TODO: find out why this one is needed.

      # get document type:
      case @document_type
      when :cnpj
        data << 49
      when :cpf
        data << 50
      else
        raise "Unknown document type received: #{@document_type}"
      end

      data += @document_number.rjust(14, "0").unpack("C*")
      data += @cei_number.rjust(12, "0").unpack("C*")
      data += @employer_name.ljust(150, 0.chr).unpack("C*")
      data += @employer_location.ljust(85, 0.chr).unpack("C*")
      data << xor(data)

      data
    end

    def get_data_from_response(payload)
      true
    end
  end
end
