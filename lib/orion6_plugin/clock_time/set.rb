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

require "orion6_plugin/clock_time"

module Orion6Plugin
  class ClockTime::Set < ClockTime
    def initialize(time, start_dst, end_dst, equipment_number, host_address, tcp_port = 3000)
      if (start_dst.nil? and end_dst.is_a?(Date) or
          start_dst.is_a?(Date) and end_dst.nil?)
        raise "Both start and end DST dates must be dates or nil"
      end

      @time = time
      @start_dst = start_dst
      @end_dst = end_dst
      @equipment_number = equipment_number
      @host_address = host_address
      @tcp_port = tcp_port
      @reponse_size = 0
    end

    private
    SET_TIME_COMMAND = 130
    SET_TIME_FIELD_QUANTITY = 1

    def get_time
      @time
    end

    def get_start_dst
      @start_dst
    end

    def get_end_dst
      @end_dst
    end

    def get_command
      SET_TIME_COMMAND
    end

    def get_field_quantity
      SET_TIME_FIELD_QUANTITY
    end

    def generate_command_data
      data = get_time_as_data_param(get_time)

      start_dst = get_start_dst
      end_dst = get_end_dst
      if start_dst and end_dst
        data += get_date_as_data_param(start_dst)
        data += get_date_as_data_param(end_dst)
      else
        data += [0, 0, 0, 0, 0, 0] # if no DST is specified just send zeros
      end
      data << crc_check(data)
      data
    end

    def get_date_as_data_param(date)
      year   = date.year % 100 # years must be of 2 digits in the clock
      month  = date.month
      day    = date.day
      [year, month, day]
    end

    def get_time_as_data_param(time)
      data = get_date_as_data_param(time)
      data << time.hour
      data << time.min
      data
    end

    def get_data_from_response(payload)
      true
    end
  end
end
