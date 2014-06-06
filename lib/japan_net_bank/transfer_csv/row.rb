require 'nkf'

module JapanNetBank
  class TransferCsv
    class Row
      RECORD_TYPE_DATA    = '1'
      RECORD_TYPE_TRAILER = '2'

      def initialize(record_type: RECORD_TYPE_DATA, bank_code:, branch_code:, account_type:, number:, name:, amount:)
        @record_type  = record_type
        @bank_code    = bank_code
        @branch_code  = branch_code
        @account_type = account_type
        @number       = number
        @name         = name
        @amount       = amount
      end

      def to_a
        [
            @record_type,
            @bank_code,
            @branch_code,
            @account_type,
            @number,
            convert_to_hankaku_shift_jis(@name),
            @amount.to_s,
        ]
      end

      private

      def convert_to_hankaku_shift_jis(string)
        NKF.nkf('-w -Z4', string).encode('Shift_JIS')
      end
    end
  end
end
