require 'japan_net_bank/transfer/data_row'
require 'japan_net_bank/transfer/trailer_row'
require 'japan_net_bank/transfer/csv'
require 'nkf'

module JapanNetBank
  class Transfer

    #
    # == row_hash, row_array, row の違い
    #
    # row_hash = {
    #     bank_code:    '0123',
    #     branch_code:  '012',
    #     account_type: 'ordinary',
    #     number:       '0123456',
    #     name:         'サトウキテコ',
    #     amount:       1600,
    # }
    #
    # row_array: ['1', '0123', '012', '1', '0123456', 'ｻﾄｳｷﾃｺ', '1600']
    #
    # row:
    #   JapanNetBank::Transfer::DataRow オブジェクト or
    #   JapanNetBank::Transfer::TrailerRow オブジェクト
    #

    FEE_TO_JAPAN_NET_BANK          = 54
    FEE_FOR_AMOUNT_UNDER_30_000    = 172
    FEE_FOR_AMOUNT_AND_OVER_30_000 = 270

    class << self
      def generate(row_hashes)
        transfer = self.new
        transfer.append_row_hashes(row_hashes)

        transfer
      end

      def parse_csv(csv_string)
        transfer        = self.new
        row_arrays      = JapanNetBank::Transfer::CSV.parse(encode_to_utf8(csv_string))
        data_row_arrays = select_data_row_arrays(row_arrays)

        transfer.append_row_arrays(data_row_arrays)

        transfer
      end

      def fee_for(bank_code: nil, amount: nil)
        raise ArgumentError if bank_code.nil? || amount.nil?

        if bank_code == JapanNetBank::BANK_CODE
          FEE_TO_JAPAN_NET_BANK
        elsif amount < 30_000
          FEE_FOR_AMOUNT_UNDER_30_000
        elsif amount >= 30_000
          FEE_FOR_AMOUNT_AND_OVER_30_000
        end
      end

      private

      def select_data_row_arrays(row_arrays)
        row_arrays.select { |row_array| row_array[0] == JapanNetBank::Transfer::DataRow::RECORD_TYPE }
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
      append_trailer_row

      JapanNetBank::Transfer::CSV.generate do |csv|
        @rows.each do |row|
          csv << row.to_a
        end
      end
    end

    def append_row_hashes(row_hashes)
      row_hashes.each do |row_hash|
        append_row_hash(row_hash)
      end
    end

    def append_row_arrays(row_arrays)
      row_arrays.each do |row_array|
        append_row_hash(row_array_to_hash(row_array))
      end
    end

    private

    def append_row_hash(row_hash)
      @rows_count   += 1
      @total_amount += row_hash[:amount].to_i
      @rows << JapanNetBank::Transfer::DataRow.new(row_hash)
    end

    def row_array_to_hash(row_array)
      {
          record_type:  row_array[0],
          bank_code:    sprintf('%04d', row_array[1]),
          branch_code:  sprintf('%03d', row_array[2]),
          account_type: JapanNetBank::Transfer::DataRow::ACCOUNT_TYPES[row_array[3]],
          number:       sprintf('%07d', row_array[4]),
          name:         row_array[5],
          amount:       row_array[6],
      }
    end

    def append_trailer_row
      return if @rows_count.zero?
      @rows << JapanNetBank::Transfer::TrailerRow.new(rows_count: @rows_count, total_amount: @total_amount)
    end
  end
end
