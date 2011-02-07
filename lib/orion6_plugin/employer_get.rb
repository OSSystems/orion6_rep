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
  class EmployerGet < MultiMessageCommand
    def initialize(equipment_number, host_address, tcp_port = 3000)
      @equipment_number = equipment_number
      @host_address = host_address
      @tcp_port = tcp_port
    end

    private
    GET_EMPLOYER_COMMAND = 128
    EMPLOYER_FIELD_SIZE  = 255
    EMPLOYER_FIELD_QUANTITY = 263

    DOCUMENT_NUMBER_RANGE = 1..14
    CEI_NUMBER_RANGE = 15..26
    COMPANY_NAME_RANGE = 27..176
    COMPANY_LOCAL_RANGE = 177..261

    def get_command
      @command ||= GET_EMPLOYER_COMMAND
    end

    def get_field_size
      EMPLOYER_FIELD_SIZE
    end

    def get_field_quantity
      EMPLOYER_FIELD_QUANTITY
    end

    def generate_command_data
      []
    end

    # Here is how the data comes from the REP:
    # 0 - Document type:
    #   49 ('1'): CNPJ
    #   50 ('2'): CPF
    # 1-14 - Document number (in hexadecimal long)
    # 15-26 - CEI Document (in hexadecimal long)
    # 27-176 - Company name
    # 177-261 - Company location
    def get_data_from_response(payload)
      hash = {}

      # get document type:
      case payload[0]
      when 49
        hash[:document_type] = :cnpj
      when 50
        hash[:document_type] = :cpf
      else
        raise "Unknown document type received: #{payload[0]}"
      end

      hash[:document_number] = payload[DOCUMENT_NUMBER_RANGE].pack("C*")
      hash[:cei_document] = payload[CEI_NUMBER_RANGE].pack("C*")
      hash[:company_name] = payload[COMPANY_NAME_RANGE].pack("C*").strip
      hash[:company_location] = payload[COMPANY_LOCAL_RANGE].pack("C*").strip
      hash
    end
  end
end
