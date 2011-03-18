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
require 'lib/orion6_plugin/interface'

module Orion6Plugin
  class DetectReps
    UDP_DETECTION_PORT = 65535
    UDP_DETECTION_DATA = [0x58].pack("C")

    def initialize
      ifaces_names = Orion6Plugin::Interface.get_active_interfaces_names
      # it's useless to try to detect REPs in the localhost
      ifaces_names.delete("lo")
      broadcast_addresses = ifaces_names.collect do |name|
        Orion6Plugin::Interface.broadcast_address(name)
      end
      raise "No active network interfaces found" if broadcast_addresses.empty?

      @responses = {}
      @broadcasts = {}
      broadcast_addresses.each do |broadcast_addr|
        socket = UDPSocket.new
        socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
        @broadcasts[broadcast_addr] = socket
      end
    end

    def execute
      @broadcasts.each do |broadcast_addr, socket|
        socket.send(UDP_DETECTION_DATA, 0, broadcast_addr, UDP_DETECTION_PORT)
      end
    end

    def pool
      rep_responses = IO.select(get_sockets, nil, nil, 1)

      unless rep_responses.nil? or rep_responses.empty?
        rep_responses.first.each do |socket|
          raw_data, socket_data = socket.recvfrom(33)
          tcp_port = raw_data.unpack("x18a4").first.to_i
          ip = socket_data.last
          @responses[ip] = tcp_port
        end
      end

      return @responses
    end

    def stop
      get_sockets.each{|socket| socket.close}
      true
    end

    private
    def get_sockets
      @broadcasts.collect{|_, socket| socket}
    end
  end
end
