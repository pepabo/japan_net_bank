require 'csv'

module JapanNetBank
  class Transfer
    class CSV
      def self.generate
        ::CSV.generate(row_sep: "\r\n", encoding: Encoding::Shift_JIS) do |csv|
          yield(csv)
        end
      end

      def self.parse(csv_string)
        ::CSV.parse(csv_string)
      end
    end
  end
end
