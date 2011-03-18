# Adapted from http://blog.frameos.org/2006/12/09/getting-network-interface-addresses-using-ioctl-pure-ruby-2/, in 23/02/2011.

require 'socket'

module Orion6Plugin
  module Interface
    # From bits/ioctls.h
    SIOCGIFHWADDR  = 0x8927 # Get hardware address
    SIOCGIFADDR    = 0x8915 # Get PA address
    SIOCGIFCONF    = 0x8912 # Get interfaces list
    SIOCGIFBRDADDR = 0x8919 # Get broadcast PA address

    STRUCT_IFREQ_SIZE   = 32
    NUM_IFREQ           = 128
    INTERFACE_NAME_SIZE = 16

    class << self
      def get_active_interfaces_names
        buffer = "\000"*(NUM_IFREQ*STRUCT_IFREQ_SIZE)
        args = [NUM_IFREQ*STRUCT_IFREQ_SIZE, buffer].pack("IP")

        socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM,0)
        socket.ioctl(SIOCGIFCONF, args)
        socket.close

        interfaces_names = []
        received_interfaces_quantity = args.unpack("I").first / STRUCT_IFREQ_SIZE
        received_interfaces_quantity.times do |i|
          position = i*STRUCT_IFREQ_SIZE
          interfaces_names << buffer[position..(position+INTERFACE_NAME_SIZE-1)].strip
        end
        interfaces_names
      end

      def hw_address(iface)
        socket = Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM,0)
        buf = [iface,""].pack('a16h16')
        socket.ioctl(SIOCGIFHWADDR, buf)
        socket.close
        to_etheraddr(buf[18..23])
      end

      def ip_address(iface)
        socket = UDPSocket.new
        buf = [iface,""].pack('a16h16')
        socket.ioctl(SIOCGIFADDR, buf)
        socket.close
        to_ipaddr4(buf[20..23])
      end

      def broadcast_address(iface)
        socket = UDPSocket.new
        buf = [iface,""].pack('a16h16')
        socket.ioctl(SIOCGIFBRDADDR, buf)
        socket.close
        to_ipaddr4(buf[20..23])
      end

      private
      def to_ipaddr4(string)
        string.unpack("CCCC").join(".")
      end

      def to_etheraddr(string)
        string.unpack("H2H2H2H2H2H2").join(":")
      end
    end
  end
end
