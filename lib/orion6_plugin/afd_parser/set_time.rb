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
  class SetTime < RecordParser
    attr_reader :line_id, :record_type_id, :before_time, :after_time
    alias :creation_time :before_time

    def initialize(line)
      self.line_id, self.record_type_id, self.before_time,
      self.after_time = line.unpack("A9AA12A12")
    end

    def export
      line_export = ""
      line_export += @line_id.to_s.rjust(9,"0")
      line_export += @record_type_id.to_s
      line_export += format_time(@before_time)
      line_export += format_time(@after_time)
      line_export
    end

    def self.size
      34
    end

    private
    def line_id=(data)
      @line_id = well_formed_number_string?(data) ? data.to_i : data
    end

    def record_type_id=(data)
      @record_type_id = well_formed_number_string?(data) ? data.to_i : data
    end

    def before_time=(raw_time)
      begin
        parsed_time = parse_time(raw_time)
        @before_time = parsed_time
      rescue
        @before_time = ""
      end
    end

    def after_time=(raw_time)
      begin
        parsed_time = parse_time(raw_time)
        @after_time = parsed_time
      rescue
        @after_time = ""
      end
    end
  end
end
