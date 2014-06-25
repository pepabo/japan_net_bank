require 'japan_net_bank/transfer/row'
require 'japan_net_bank/transfer/csv'
require 'nkf'

module JapanNetBank
  class Transfer
    class << self
      def parse_csv(csv_string)
        parsed_data = JapanNetBank::Transfer::CSV.parse(encode_to_utf8(csv_string))

        select_data_records(parsed_data).map { |row|
          JapanNetBank::Transfer::Row.new(
              record_type:  row[0],
              bank_code:    sprintf('%04d', row[1]),
              branch_code:  sprintf('%03d', row[2]),
              account_type: JapanNetBank::Transfer::Row::ACCOUNT_TYPES[row[3]],
              number:       sprintf('%07d', row[4]),
              name:         row[5],
              amount:       row[6],
          )
        }
      end

      private

      def select_data_records(rows)
        rows.select { |row| row[0] == JapanNetBank::Transfer::Row::RECORD_TYPE_DATA }
      end

      def encode_to_utf8(string)
        NKF.nkf('-w -X', string)
      end
    end

    attr_reader :rows_count, :total_amount, :rows

    def initialize(rows)
      @rows         = []
      @rows_count   = 0
      @total_amount = 0

      rows.each do |row|
        append_row(row)
      end

      add_trailer_row
    end

    def to_csv
      csv_string = JapanNetBank::Transfer::CSV.generate do |csv|
        @rows.each do |row|
          csv << row
        end
      end

      csv_string
    end

    private

    def append_row(row)
      @rows_count   += 1
      @total_amount += row[:amount].to_i
      @rows << JapanNetBank::Transfer::Row.new(row).to_a
    end

    def add_trailer_row
      return if @rows_count.zero?
      @rows << trailer_row
    end

    def trailer_row
      [Row::RECORD_TYPE_TRAILER, nil, nil, nil, nil, @rows_count, @total_amount]
    end
  end
end
