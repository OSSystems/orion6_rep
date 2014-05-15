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
require 'timeout'

module Orion6Rep
  module Communication
    include Timeout

    class << self
      def communicate(host_address, port, payload, expected_response_size, timeout_time=60, max_attempts = 3)
        attempt = 0

        while attempt < max_attempts do
          socket = TCPSocket.open(host_address, port)
          begin
            received_data = nil
            received_data = send_receive_data(socket, payload, expected_response_size, timeout_time)
          rescue Timeout::Error => e
            received_data = nil
          end
          socket.close
          break unless received_data.nil?
          attempt += 1
        end

        raise "Timeout error" if attempt >= max_attempts
        received_data
      end

      private
      def send_receive_data(socket, data_to_send, expected_response_size, timeout_time)
        socket.write(data_to_send.pack("C*"))
        socket.flush
        data_to_receive = ""

        # expected_response_size can be a Fixnum, for fixed responses sizes, or
        # a proc, where the response size comes inside the response itself.
        if expected_response_size.is_a?(Proc)
          expected_size = expected_response_size.call(data_to_receive)
        else
          expected_size = expected_response_size
        end

        while data_to_receive.size < expected_size
          bytes_to_be_read = expected_size - data_to_receive.size
          bytes_to_be_read = 100 if bytes_to_be_read > 100

          timeout(timeout_time) {
            data_to_receive += socket.readpartial( bytes_to_be_read )
          }
          if expected_response_size.is_a?(Proc)
            expected_size = expected_response_size.call(data_to_receive)
          end
        end
        data_to_receive
      end
    end
  end
end
