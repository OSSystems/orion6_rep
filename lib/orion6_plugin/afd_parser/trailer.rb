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
  class Trailer < RecordParser
    attr_reader :line_id, :set_employer, :clock_in_out, :set_time, :set_employee, :record_type_id

    def initialize(*args)
      if args.size == 1
        counter = args[0]
        @line_id = 999999999
        @set_employer = counter[:set_employer]
        @clock_in_out = counter[:clock_in_out]
        @set_time = counter[:set_time]
        @set_employee = counter[:set_employee]
        @record_type_id = 9

      elsif args.size == 2
        line = args[0]
        counter = args[1]

        line_id, set_employer, clock_in_out, set_time, set_employee, record_type_id = line.unpack("A9A9A9A9A9A")

        @line_id = line_id.to_i
        @set_employer = set_employer.to_i
        @clock_in_out = clock_in_out.to_i
        @set_time = set_time.to_i
        @set_employee = set_employee.to_i
        @record_type_id = record_type_id.to_i

        ["set_employer", "clock_in_out", "set_time", "set_employee"].each do |key|
          value = eval("@"+key)
          if value != counter[key.to_sym]
            raise AfdParserException.new("Mismatch counting changes of #{key} in REP!\n" +
                                         "REP: #{value.to_s} | System: #{counter[key.to_sym].to_s}")
          end
        end

      else
        raise AfdParserException.new("wrong number of arguments for trailer object, should be 1 or 2")
      end
    end

    def export
      line_export = ""
      line_export += @line_id.to_s.rjust(9,"0")
      line_export += @set_employer.to_s.rjust(9,"0")
      line_export += @clock_in_out.to_s.rjust(9,"0")
      line_export += @set_time.to_s.rjust(9,"0")
      line_export += @set_employee.to_s.rjust(9,"0")
      line_export += @record_type_id.to_s
      line_export
    end

    def self.time
      46
    end
  end
end
