# -*- coding: utf-8 -*-
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

require 'socket'
require 'ipaddr'
require 'orion6_rep/interface'

module Orion6Rep
  class ChangeIp
    UDP_PORT = 65535

    def initialize(interface, new_ip, rep_data)
      @broadcast_address = Orion6Rep::Interface.broadcast_address(interface)
      raise "Network interface '#{interface}' not found or doesn't have a broadcast address" if @broadcast_address.nil?

      @new_ip = IPAddr.new(new_ip)
      # TODO: find what the REP data actually is
      @rep_data = rep_data
      @payload = prepare_payload_data
      @socket = UDPSocket.new
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    end

    def execute
      @socket.send(@payload, 0, @broadcast_address, UDP_PORT)
      responses = IO.select([@socket], nil, nil, 1)
      raw_data, socket_data = responses.first.first.recvfrom(1)
      rep_current_ip = IPAddr.new(socket_data.last)
      return (rep_current_ip == @new_ip ? true : execute)
    end

    private
    def prepare_payload_data
      @rep_data + "//" + @new_ip.to_s
    end
  end
end
