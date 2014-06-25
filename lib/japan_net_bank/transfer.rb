require 'japan_net_bank/transfer/row'
require 'japan_net_bank/transfer/csv'

module JapanNetBank
  class Transfer
    attr_reader :rows_count, :total_amount, :rows

    FEE_TO_JAPAN_NET_BANK          = 52
    FEE_FOR_AMOUNT_UNDER_30_000    = 172
    FEE_FOR_AMOUNT_AND_OVER_30_000 = 270

    def self.fee_for(bank_code: nil, amount: nil)
      raise ArgumentError if bank_code.nil? || amount.nil?

      if bank_code == JapanNetBank::BANK_CODE
        FEE_TO_JAPAN_NET_BANK
      elsif amount < 30_000
        FEE_FOR_AMOUNT_UNDER_30_000
      elsif amount >= 30_000
        FEE_FOR_AMOUNT_AND_OVER_30_000
      end
    end

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
