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
require 'timeout'

module Orion6Plugin
  module Communication
    include Timeout

    class << self
      def communicate(host_address, port, payload, timeout_time = 3, max_attempts = 3)
        status, received_data = nil
        attempt = 0
        while attempt < max_attempts do
          socket = TCPSocket.open(host_address, port)
          begin
            timeout(timeout_time) {
              received_data = send_receive_data(socket, payload)
            }
          rescue Timeout::Error => e
            # Timeout
          end
          socket.close
          break if status
          attempt += 1
        end
        received_data
      end

      private
      def send_receive_data(socket, data)
        socket.write(data.pack("C*"))
        socket.flush
        sleep 0.2
        socket.recvfrom( 10000 ).first.unpack("C*")
      end
    end
  end
end
