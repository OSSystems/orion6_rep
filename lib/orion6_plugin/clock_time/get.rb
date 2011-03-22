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

require "lib/orion6_plugin/clock_time"

module Orion6Plugin
  class ClockTime::Get < ClockTime
    def initialize(equipment_number, host_address, tcp_port = 3000)
      @equipment_number = equipment_number
      @host_address = host_address
      @tcp_port = tcp_port
      @reponse_size = 12
    end

    private
    GET_TIME_COMMAND = 146
    GET_TIME_FIELD_QUANTITY = 0

    def get_command
      GET_TIME_COMMAND
    end

    def get_field_quantity
      GET_TIME_FIELD_QUANTITY
    end

    def generate_command_data
      []
    end

    def get_data_from_response(payload)
      # the time comes in a array of unsigned integers, using the following
      # format. The purpose of the last byte is unknown, but it is probably
      # some form of data check.
      #
      # Example:
      # |   current time   | DST Start |  DST End  |
      # [yy, mm, dd, hh, mm, yy, mm, dd, yy, mm, dd]
      # [11,  1, 21, 15, 17, 10, 10, 17, 11,  2, 20]
      #
      # These would be:
      # - Current Time: 21/01/2011 15:17
      # - DST Start:    17/10/2010
      # - DST Start:    20/02/2011

      time_payload = payload.unpack("C5")
      dst_start_payload = payload[5..-1].unpack("C3")
      dst_end_payload = payload[8..-1].unpack("C3")

      time = parse_time(time_payload)

      isDstOn = dst_start_payload.any?{|d| d > 0}

      if isDstOn
        start_dst = parse_date(dst_start_payload)
        end_dst   = parse_date(dst_end_payload)
      end
      [time, start_dst, end_dst]
    end

    def parse_date(date_array)
      year = defineCentury(date_array[0])
      month = date_array[1]
      day = date_array[2]
      Date.civil(year,month,day)
    end

    def parse_time(date_array)
      year = defineCentury(date_array[0])
      month = date_array[1]
      day = date_array[2]
      hour = date_array[3]
      minute = date_array[4]
      DateTime.civil(year,month,day,hour,minute).to_time
    end

    def defineCentury(year)
      year > 79 ? year + 1900 : year + 2000
    end
  end
end
