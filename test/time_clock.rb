require 'orion6_plugin/orion6'

class TimeClock
  include Orion6Plugin::Orion6

  attr_accessor :ip, :tcp_port, :number

  def initialize(ip, tcp_port, number)
    @ip = ip
    @tcp_port = tcp_port
    @number = number
  end
end
