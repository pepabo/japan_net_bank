require 'csv'
require 'japan_net_bank/transfer_csv/row'

module JapanNetBank
  class TransferCsv
    def self.generate
      transfer_csv = new
      yield transfer_csv
      transfer_csv.add_trailer_row
      transfer_csv.string
    end

    def initialize
      @csv          = CSV.new('', row_sep: "\r\n")
      @rows_count   = 0
      @total_amount = 0
    end

    def string
      @csv.string
    end

    def <<(row)
      @rows_count   += 1
      @total_amount += row[:amount].to_i
      @csv << JapanNetBank::TransferCsv::Row.new(row).to_a
    end

    def add_trailer_row
      return if @rows_count.zero?
      @csv << trailer_row
    end

    private

    def trailer_row
      [Row::RECORD_TYPE_TRAILER, nil, nil, nil, nil, @rows_count, @total_amount]
    end
  end
end