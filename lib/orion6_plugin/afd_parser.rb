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

require 'date'

require 'lib/orion6_plugin/afd_parser/clock_in_out'
require 'lib/orion6_plugin/afd_parser/header'
require 'lib/orion6_plugin/afd_parser/set_employee'
require 'lib/orion6_plugin/afd_parser/set_employer'
require 'lib/orion6_plugin/afd_parser/set_time'
require 'lib/orion6_plugin/afd_parser/trailer'

# Parser para a PORTARIA No 1.510, DE 21 DE AGOSTO DE 2009, do
# Ministério do Trabalho;

class AfdParser
  class AfdParserException < Exception; end

  attr_reader :records

  def initialize(*args)
    if args.size == 1
      initialize_variables(args[0])
    elsif args.size == 2
      initialize_variables(args[1])
      File.open(args[0], "r") do |file|
        @raw_data = file.readlines
      end
    else
      raise AfdParserException.new("wrong number of arguments, should be 1 or 2")
    end
  end

  def parse
    @raw_data.each_with_index do |line, index|
      parse_line(line, index)
    end

    if @validate_structure and not trailer_found?
      raise AfdParserException.new("AFD ended without a trailer record")
    end
  end

  def parse_line(line, index)
    line_id, record_type_id = line.unpack("A9A").collect{|id| id.to_i}
    record_type = get_record_type(line_id, record_type_id, line)

    if @validate_structure
      validate_afd(line, line_id, index, record_type)
    end

    case record_type
    when :header
      @records << Header.new(line)
    when :set_employer
      @records << SetEmployer.new(line)
      @counter[:set_employer] += 1
    when :clock_in_out
      @records << ClockInOut.new(line)
      @counter[:clock_in_out] += 1
    when :set_time
      @records << SetTime.new(line)
      @counter[:set_time] += 1
    when :set_employee
      @records << SetEmployee.new(line)
      @counter[:set_employee] += 1
    when :trailer
      @records << Trailer.new(line, @counter)
    else
      if @validate_structure
        raise AfdParserException.new("Unknown record type found in AFD file, line #{index.to_s}: '#{line}'")
      end
    end

    @records.last
  end

  def create_header(employer_type, employer_document, employer_cei, employer_name, rep_serial_number, afd_start_date,afd_end_date, afd_creation_time)
    if header_found?
      raise AfdParserException.new("Cannot add a second AFD header")
    else
      @records.unshift Header.new(employer_type, employer_document, employer_cei, employer_name, rep_serial_number, afd_start_date,afd_end_date, afd_creation_time)
    end
  end

  def create_trailer
    if trailer_found?
      raise AfdParserException.new("Cannot add a second AFD trailer")
    else
      @records << Trailer.new(@counter)
    end
  end

  def export
    exported_data = ""
    @records.each do |record|
      exported_data += record.export + "\r\n"
    end

    exported_data
  end

  def first_creation_date
    unless @records.empty?
      time = @records.first.creation_time
      return Date.civil(time.year, time.month, time.day)
    end
  end

  def last_creation_date
    unless @records.empty?
      time = @records.last.creation_time
      return Date.civil(time.year, time.month, time.day)
    end
  end

  private
  def initialize_variables(validate_structure)
    @records = []
    @counter = {:set_employer => 0, :clock_in_out => 0, :set_time => 0, :set_employee => 0}
    @validate_structure = validate_structure
  end

  def get_record_type(line_id, record_type_id, line)
    if record_type_id == 1
      return :header
    elsif line_id == 999999999 and line.unpack("x45A").first.to_i == 9
      return :trailer
    elsif line_id != 0
      case record_type_id
      when 2
        return :set_employer
      when 3
        return :clock_in_out
      when 4
        return :set_time
      when 5
        return :set_employee
      end
    end

    return nil
  end

  def validate_afd(line, line_id, index, record_type)
    raise AfdParserException.new("Line #{index.to_s} is blank") if line.blank?

    if line_id != index and not (line_id == 999999999 and not trailer_found?)
      raise AfdParserException.new("Out-of-order line id on line 1; expected '#{index.to_s}', got '#{line_id.to_s}'")
    end

    if trailer_found?
      raise AfdParserException.new("Unexpected AFD record found after trailer, line #{index.to_s}: '#{line}'")
    end

    if not header_found? and record_type != :header
      raise AfdParserException.new("Unexpected AFD record found before header, line #{index.to_s}: '#{line}'")
    end

    if header_found? and record_type == :header
      raise AfdParserException.new("Unexpected second AFD header found, line #{index.to_s}: '#{line}'")
    end

  end

  def header_found?
    @records.first.class == Header
  end

  def trailer_found?
    @records.last.class == Trailer
  end
end
