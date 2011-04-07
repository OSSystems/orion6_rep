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

require File.dirname(__FILE__) + '/../test_helper'

class TimeTest < Test::Unit::TestCase
  def test_get_set_time
    ip = ENV["IP"]
    t = TimeClock.new(ip, 3000, 1)

    puts "Retrieving time from '#{ip}'..."
    original_time_array = t.get_time
    original_time = original_time_array[0]
    difference = (Time.now - original_time).truncate
    puts "Received: "
    puts "  Time:      " + original_time_array[0].to_s
    puts "  DST Start: " + original_time_array[1].to_s
    puts "  DST End:   " + original_time_array[2].to_s

    puts "\nSetting time to tomorrow..."
    new_time = change_time(original_time_array[0], :day, 1)
    t.set_time(new_time).to_s
    new_array = t.get_time
    puts "Received: "
    puts "  Time:      " + new_array[0].to_s
    puts "  DST Start: " + new_array[1].to_s
    puts "  DST End:   " + new_array[2].to_s

    puts "\nSetting time to tomorrow and with DST starting one month earlier and ending one month after..."
    new_time = change_time(original_time_array[0], :day, 1)
    dst_start = change_time(original_time_array[0], :month, 1)
    dst_end = change_time(original_time_array[0], :month, 1)
    t.set_time(new_time, dst_start, dst_end).to_s
    new_array = t.get_time
    puts "Received: "
    puts "  Time:      " + new_array[0].to_s
    puts "  DST Start: " + new_array[1].to_s
    puts "  DST End:   " + new_array[2].to_s

    puts "\nRestoring time..."
    new_time = Time.now
    dst_start = original_time_array[1]
    dst_end = original_time_array[2]
    puts "Received: " + t.set_time(new_time, dst_start, dst_end).to_s
  end

  private
  def change_time(time, time_part, difference)
    year, month, day, hour, minute, second = [time.year, time.month, time.day, time.hour, time.min, time.sec]
    case time_part
    when :year
      year += difference.to_i
    when :month
      month += difference.to_i
    when :day
      day += difference.to_i
    when :hour
      hour += difference.to_i
    when :minute
      minute += difference.to_i
    when :second
      second += difference.to_i
    else
      raise "unknow time part '#{time_part}'"
    end
    Time.local(year,month,day,hour,minute)
  end
end
