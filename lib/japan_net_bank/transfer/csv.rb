require 'csv'

module JapanNetBank
  class Transfer
    class CSV
      def self.generate
        csv = ::CSV.new('', row_sep: "\r\n", force_quotes: true)
        yield(csv)
        csv.string
      end

      def self.parse(csv_string)
        ::CSV.parse(csv_string)
      end
    end
  end
end
