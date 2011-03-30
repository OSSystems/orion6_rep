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

require 'lib/orion6_plugin/afd_parser/record_parser'

class AfdParser
  class Header < RecordParser
    attr_reader :line_id, :record_type_id, :employer_type, :employer_document, :employer_cei, :employer_name, :rep_serial_number, :afd_start_date, :afd_end_date, :afd_creation_time

    EMPLOYER_TYPES = {1 => :cnpj, 2 => :cpf}

    def initialize(*args)
      if args.size == 1
        line = args[0]

        self.line_id, self.record_type_id, self.employer_type, self.employer_document,
        self.employer_cei, self.employer_name, self.rep_serial_number, self.afd_start_date,
        self.afd_end_date, self.afd_creation_time = line.unpack("A9AAA14A12A150A17A8A8A12")
      elsif args.size == 8
        @line_id           = 0
        @record_type_id    = 1
        @employer_type     = args[0]
        @employer_document = args[1]
        @employer_cei      = args[2]
        @employer_name     = args[3]
        @rep_serial_number = args[4]
        @afd_start_date    = args[5]
        @afd_end_date      = args[6]
        @afd_creation_time = args[7]
      else
        raise AfdParserException.new("wrong number of arguments for header object, should be 1 or 8")
      end
    end

    def export
      line_export = ""
      line_export += @line_id.to_s.rjust(9,"0")
      line_export += @record_type_id.to_s
      line_export += get_employer_type_number(@employer_type).to_s
      line_export += @employer_document.to_s.rjust(14, "0")
      line_export += @employer_cei.to_s.rjust(12, "0")
      line_export += @employer_name.to_s.ljust(150, " ")
      line_export += @rep_serial_number
      line_export += format_date(@afd_start_date)
      line_export += format_date(@afd_end_date)
      line_export += format_time(@afd_creation_time)
      line_export
    end

    def self.size
      232
    end

    private
    def line_id=(data)
      @line_id = well_formed_number_string?(data) ? data.to_i : data
    end

    def record_type_id=(data)
      @record_type_id = well_formed_number_string?(data) ? data.to_i : data
    end

    def employer_type=(data)
      @employer_type = get_employer_type(data.to_i)
    end

    def employer_document=(data)
      @employer_document = well_formed_number_string?(data) ? data.to_i : data
    end

    def employer_cei=(data)
      @employer_cei = well_formed_number_string?(data) ? data.to_i : data
    end

    def employer_name=(data)
      @employer_name = data.rstrip
    end

    def rep_serial_number=(data)
      @rep_serial_number = data
    end

    def afd_start_date=(raw_date)
      begin
        parsed_date = parse_date(raw_date)
        @afd_start_date = parsed_date
      rescue
        @afd_start_date = ""
      end
    end

    def afd_end_date=(raw_date)
      begin
        parsed_date = parse_date(raw_date)
        @afd_end_date = parsed_date
      rescue
        @afd_end_date = ""
      end
    end

    def afd_creation_time=(raw_time)
      begin
        parsed_time = parse_time(raw_time)
        @afd_creation_time = parsed_time
      rescue
        @afd_creation_time = ""
      end
    end

    def get_employer_type(employer_type_id)
      type = EMPLOYER_TYPES[employer_type_id]
      if type.nil?
        raise AfdParserException.new("Unknown employer type id '#{employer_type_id.to_s}' found in AFD header")
      end
      type
    end

    def get_employer_type_number(employer_type)
      EMPLOYER_TYPES.invert[employer_type]
    end
  end
end
