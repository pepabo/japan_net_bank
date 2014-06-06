require 'csv'
require 'japan_net_bank/transfer_csv/row'

module JapanNetBank
  class TransferCsv
    def self.generate
      transfer_csv = new
      yield transfer_csv
      transfer_csv.string
    end

    def initialize
      @csv          = CSV.new('', row_sep: "\r\n")
      @row_count    = 0
      @total_amount = 0
    end

    def string
      @csv.string
    end

    def <<(row)
      @row_count    += 1
      @total_amount += row[:amount].to_i
      @csv << JapanNetBank::TransferCsv::Row.new(row).to_a
    end
  end
end
