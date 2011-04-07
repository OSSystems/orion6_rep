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
require 'orion6_rep/interface'

module Orion6Rep
  class DetectReps
    UDP_DETECTION_PORT = 65535
    UDP_DETECTION_DATA = [0x58].pack("C")

    def initialize
      ifaces_names = Orion6Rep::Interface.get_active_interfaces_names
      # it's useless to try to detect REPs in the localhost
      ifaces_names.delete("lo")

      @interfaces = {}
      @responses = {}
      ifaces_names.each do |name|
        broadcast_address = Orion6Rep::Interface.broadcast_address(name)
        @interfaces[name] = {}
        @interfaces[name][:broadcast_addr] = broadcast_address
      end
      raise "No active network interfaces found" if @interfaces.empty?

      @interfaces.each_key do |name|
        socket = UDPSocket.new
        socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
        @interfaces[name][:socket] = socket
      end
    end

    def execute
      @interfaces.each do |_, data|
        data[:socket].send(UDP_DETECTION_DATA, 0, data[:broadcast_addr], UDP_DETECTION_PORT)
      end
    end

    def pool
      rep_responses = IO.select(get_sockets, nil, nil, 1)

      unless rep_responses.nil? or rep_responses.empty?
        rep_responses.first.each do |socket|
          raw_data, socket_data = socket.recvfrom(33)
          rep_data, tcp_port = raw_data.unpack("a18a4")
          ip = socket_data.last
          interface = get_assossiated_interface(socket)
          @responses[interface] = {} if @responses[interface].nil?
          @responses[interface][ip] = {:port => tcp_port.to_i, :rep_data => rep_data}
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
      @interfaces.collect{|_, data| data[:socket]}
    end

    def get_assossiated_interface(socket)
      @interfaces.each{|interface, data| return interface if data[:socket] == socket}
    end
  end
end
