require 'japan_net_bank/transfer/data_row'
require 'japan_net_bank/transfer/trailer_row'
require 'japan_net_bank/transfer/csv'
require 'nkf'

module JapanNetBank
  class Transfer
    class << self
      def generate(rows)
        transfer = self.new
        transfer.append_rows(rows)
        transfer.append_trailer_row

        transfer
      end

      def parse_csv(csv_string)
        transfer    = self.new
        parsed_rows = JapanNetBank::Transfer::CSV.parse(encode_to_utf8(csv_string))
        data_rows   = select_data_rows(parsed_rows)

        transfer.append_data_rows(data_rows)

        transfer
      end

      private

      def select_data_rows(parsed_rows)
        parsed_rows.select { |parsed_row| parsed_row[0] == JapanNetBank::Transfer::DataRow::RECORD_TYPE }
      end

      def encode_to_utf8(string)
        # 単純に下記だと、"カ)" の部分が落ちてしまうため
        # NKF.nkf('-w -X', string)

        NKF.nkf('-w -X', string.encode('UTF-8', NKF.guess(string).to_s))
      end
    end

    attr_reader :rows_count, :total_amount, :rows

    def initialize
      @rows         = []
      @rows_count   = 0
      @total_amount = 0
    end

    def to_csv
      csv_string = JapanNetBank::Transfer::CSV.generate do |csv|
        @rows.each do |row|
          csv << row.to_a
        end
      end

      csv_string
    end

    def append_rows(rows)
      rows.each do |row|
        append_row(row)
      end
    end

    def append_trailer_row
      return if @rows_count.zero?
      @rows << trailer_row
    end

    def append_data_rows(data_rows)
      data_rows.each do |data_row|
        @rows_count   += 1
        @total_amount += data_row[6].to_i
        @rows << JapanNetBank::Transfer::DataRow.new(data_row_to_hash(data_row))
      end
    end

    private

    def append_row(row)
      @rows_count   += 1
      @total_amount += row[:amount].to_i
      @rows << JapanNetBank::Transfer::DataRow.new(row)
    end

    def data_row_to_hash(data_row)
      {
          record_type:  data_row[0],
          bank_code:    sprintf('%04d', data_row[1]),
          branch_code:  sprintf('%03d', data_row[2]),
          account_type: JapanNetBank::Transfer::DataRow::ACCOUNT_TYPES[data_row[3]],
          number:       sprintf('%07d', data_row[4]),
          name:         data_row[5],
          amount:       data_row[6],
      }
    end

    def trailer_row
      JapanNetBank::Transfer::TrailerRow.new(rows_count: @rows_count, total_amount: @total_amount)
    end
  end
end
