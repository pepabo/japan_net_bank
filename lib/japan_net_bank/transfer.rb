require 'csv'
require 'japan_net_bank/transfer/row'

module JapanNetBank
  class Transfer
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
      # TODO: あとで実装する
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
