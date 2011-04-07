require 'orion6_rep'

class TimeClock
  include Orion6Rep

  attr_accessor :ip, :tcp_port, :number

  def initialize(ip, tcp_port, number)
    @ip = ip
    @tcp_port = tcp_port
    @number = number
  end
end
