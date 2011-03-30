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
  class SetEmployer < RecordParser
    attr_accessor :line_id, :record_type_id, :creation_time, :document_type,
    :document_number, :cei, :name, :location

    DOCUMENT_TYPES = {1 => :cnpj, 2 => :cpf}

    def initialize(line)
      self.line_id, self.record_type_id, self.creation_time,
      self.document_type, self.document_number, self.cei, self.name,
      self.location = line.unpack("A9AA12AA14A12A150A100")
    end

    def export
      line_export = ""
      line_export += @line_id.to_s.rjust(9,"0")
      line_export += @record_type_id.to_s
      line_export += format_time(@creation_time)
      line_export += get_document_type_number(@document_type).to_s
      line_export += @document_number.to_s.rjust(14, "0")
      line_export += @cei.to_s.rjust(12, "0")
      line_export += @name.ljust(150, " ")
      line_export += @location.ljust(100, " ")
      line_export
    end

    def self.size
      299
    end

    private
    def line_id=(data)
      @line_id = well_formed_number_string?(data) ? data.to_i : data
    end

    def record_type_id=(data)
      @record_type_id = well_formed_number_string?(data) ? data.to_i : data
    end

    def document_type=(data)
      @document_type = get_document_type(data.to_i)
    end

    def document_number=(data)
      @document_number = well_formed_number_string?(data) ? data.to_i : data
    end

    def cei=(data)
      @cei = well_formed_number_string?(data) ? data.to_i : data
    end

    def name=(data)
      @name = data.rstrip
    end

    def location=(data)
      @location = data.rstrip
    end

    def creation_time=(raw_time)
      begin
        parsed_time = parse_time(raw_time)
        @creation_time = parsed_time
      rescue
        @creation_time = ""
      end
    end

    def get_document_type(document_type_id)
      type = DOCUMENT_TYPES[document_type_id]
      if type.nil?
        raise AfdParserException.new("Unknown employer type id '#{document_type_id.to_s}' found in set employer record on line #{@line_id.to_s}")
      end
      type
    end

    def get_document_type_number(document_type_id)
      DOCUMENT_TYPES.invert[document_type_id]
    end
  end
end
