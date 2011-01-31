require 'socket'

module Orion6Plugin
  module Orion6
    SET_TIME_COMMAND = 130
    GET_TIME_COMMAND = 146
    # TODO: find what is this constant. It's the size of something, perhaps?
    UNKNOWN_CONSTANT = 113
    TIME_FIELD_SIZE  = 11
    SET_TIME_FIELD_QUANTITY = 1
    GET_TIME_FIELD_QUANTITY = 0

    class << self
      def get_time(equipment_number, host_address, port)
        # first set the header:
        payload = generate_header(equipment_number, false)

        # now send it!
        socket = open_socket(host_address, port)
        response = send_data(socket, payload)
        close_socket(socket)

        # check everything:
        check_response_header(response)
        check_response_payload(response)

        # and then get and process the response payload:
        payload = get_response_payload(response)
        puts get_time_from_response(payload).inspect
      end

      def set_time(equipment_number, host_address, port, time, start_dst = nil, end_dst = nil)
        if (start_dst.nil? and end_dst.is_a?(Date) or
            start_dst.is_a?(Date) and end_dst.nil?)
          raise "Both start and end DST dates must be dates or nil"
        end

        # first set the header:
        payload = generate_header(equipment_number, true)

        # now comes the data:
        payload += generate_set_data(time,start_dst,end_dst)

        # now send it!
        socket = open_socket(host_address, port)
        puts send_data(socket, payload).inspect
        close_socket(socket)
      end

      private
      def check_response_header(response)
        # FIXME: add a real check here
        true
      end

      def check_response_payload(response)
        # FIXME: add a real check here
        true
      end

      def get_response_payload(response)
        # TODO: other payloads might be different
        response[8..-1]
      end

      def generate_header(equipment_number, set_time)
        if set_time
          command = SET_TIME_COMMAND
          field_quantity = SET_TIME_FIELD_QUANTITY
        else
          command = GET_TIME_COMMAND
          field_quantity = GET_TIME_FIELD_QUANTITY
        end
        header = [equipment_number^255] # TODO: find why this is needed
        header << command
        header << UNKNOWN_CONSTANT
        header << 0 # TODO: find why this is needed
        header << TIME_FIELD_SIZE
        header << field_quantity
        header << divide_by_256(field_quantity)
        header << xor(header) # TODO: find why this is needed; maybe a data check?
        header
      end

      def generate_set_data(time,start_dst,end_dst)
        data = get_time_as_data_param(time)
        if start_dst and end_dst
          data += get_date_as_data_param(start_dst)
          data += get_date_as_data_param(end_dst)
        else
          data += [0, 0, 0, 0, 0, 0] # no dst specified, just send zeros
        end
        data << xor(data) # TODO: find why this is needed; maybe a data check?
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

      def divide_by_256(value)
        return (value >> 8 & 255)
      end

      def xor(data)
        value = 0;
        data.each do |integer|
          value ^= integer
        end
        value
      end

      def open_socket(host_address, port)
        TCPSocket.open(host_address, port)
      end

      def send_data(socket, data)
        socket.write(data.pack("C*"))
        socket.flush
        sleep 0.2
        socket.recvfrom( 10000 ).first.unpack("C*")
      end

      def close_socket(socket)
        socket.close
      end

      def get_time_from_response(raw_data)
        # the time comes in a array of unsigned integers, using the following
        # format:
        # [yy, mm, dd, hh, mm, yy, mm, dd, yy, mm, dd, ??]
        # [11,  1, 21, 15, 17, 11,  3, 20, 11,  3, 20,  1]

        time = parse_time(raw_data[0..4])
        isDstOn = raw_data[5] > 0;

        if isDstOn
          start_dst = parse_date(raw_data[5..7])
          end_dst   = parse_date(raw_data[8..10])
        end
        [time, start_dst, end_dst]
      end

      def defineCentury(year)
        year > 79 ? year + 1900 : year + 2000
      end

      def parse_date(date_array)
        year = defineCentury(date_array[0])
        month = date_array[1]
        day = date_array[2]
        Date.civil(year,month,day)
      end

      def parse_time(date_array)
        year = defineCentury(date_array[0])
        month = date_array[1]
        day = date_array[2]
        hour = date_array[3]
        minute = date_array[4]
        DateTime.civil(year,month,day,hour,minute).to_time
      end
    end
  end
end
