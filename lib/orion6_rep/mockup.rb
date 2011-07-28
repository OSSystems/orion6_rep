require 'orion6_rep'

module Orion6Rep
  module Mockup
    [:mock_detect_reps, :mock_time, :mock_employer, :mock_employees, :mock_ip,
     :mock_serial_number, :mock_records, :mock_detection_data].each do |sym|
      class_eval("@@#{sym} = nil unless defined? @@#{sym}; def self.#{sym}; @@#{sym}; end; def self.#{sym}=(obj); @@#{sym} = obj; end", __FILE__, __LINE__ + 1)
    end

    self.mock_employees = {}
    self.mock_detection_data = {}

    Orion6Rep::ClassMethods.module_eval do
      def detect_reps
        Orion6Rep::Mockup.mock_detection_data
      end
    end

    Orion6Rep::InstanceMethods.module_eval do
      def get_time
        Orion6Rep::Mockup.mock_time
      end

      def set_time(time, start_dst = nil, end_dst = nil)
        Orion6Rep::Mockup.mock_time = time
      end

      def get_employer
        Orion6Rep::Mockup.mock_employer
      end

      def set_employer(employer_name, employer_location, document_type, document_number, cei_number)
        Orion6Rep::Mockup.mock_employer = {:company_name => employer_name, :company_location => employer_location, :document_type => document_type, :document_number => document_number, :cei_number => cei_number}
      end

      def get_employees_quantity
        employees = Orion6Rep::Mockup.mock_employees
        (employees.nil? || employees.empty?) ? 0 : employees.size
      end

      def get_employees(quantity = get_employees_quantity)
        Orion6Rep::Mockup.mock_employees.keys.sort[0..quantity].collect do |registration|
          employee = Orion6Rep::Mockup.mock_employees[registration]
          {:registration => registration, :pis_number => employee[:pis_number], :name => employee[:name]}
        end
      end

      def set_employee(operation_type, registration, pis_number, name)
        case operation_type
        when :add, :edit
          Orion6Rep::Mockup.mock_employees[registration.to_i] = {:pis_number => pis_number, :name => name}
        when :remove
          Orion6Rep::Mockup.mock_employees.delete registration
        else
          raise "Unknown employee operation type received: #{operation_type.to_s}"
        end
      end

      def change_ip(new_ip, interface = nil, rep_data = nil)
        Orion6Rep::Mockup.mock_ip = new_ip
      end

      def get_serial_number
        Orion6Rep::Mockup.mock_serial_number
      end

      def get_record_id(datetime)
        record = Orion6Rep::Mockup.mock_records.records.detect do |record|
          record.respond_to?(:creation_time) && record.creation_time >= datetime
        end
        record ? record.line_id : nil
      end

      def get_records(first_id = nil)
        (first_id = 1) if first_id.nil?
        requested_id = first_id
        parser = AfdParser.new(false)

        Orion6Rep::Mockup.mock_records.records.each do |record|
          next if(record.line_id < requested_id ||
                  record.class == AfdParser::Header ||
                  record.class == AfdParser::Trailer)
          parser.parse_line(record.export, record.line_id)
        end

        afd_start_date = parser.first_creation_date
        afd_end_date = parser.last_creation_date
        employer = get_employer
        serial_number = get_serial_number
        parser.create_header(employer[:document_type], employer[:document_number],
                             employer[:cei_document], employer[:company_name],
                             serial_number, afd_start_date, afd_end_date, Time.now)
        parser.create_trailer
        return parser
      end

      def set_records(parser)
        Orion6Rep::Mockup.mock_records = parser
      end
    end
  end
end
