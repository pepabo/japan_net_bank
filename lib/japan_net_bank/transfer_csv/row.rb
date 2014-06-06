require 'nkf'
require 'active_model'
require 'active_support'

module JapanNetBank
  class TransferCsv
    class Row
      include ActiveModel::Validations

      attr_accessor :record_type, :bank_code, :branch_code, :account_type, :number, :name, :amount

      RECORD_TYPE_DATA    = '1'
      RECORD_TYPE_TRAILER = '2'

      validates :bank_code, format: { with: /\A\d{4}\z/ }
      validates :branch_code, format: { with: /\A\d{3}\z/ }
      validates :account_type, inclusion: { in: %w(ordinary checking savings) }
      validates :number, format: { with: /\A\d{7}\z/ }
      validates :name, presence: true

      validates :amount,
          numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1
          }

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
            account_type_code,
            @number,
            convert_to_hankaku_katakana(@name).encode('Shift_JIS'),
            @amount.to_s,
        ]
      end

      private

      def convert_to_hankaku_katakana(string)
        NKF.nkf('-w -Z4', string)
      end

      def account_type_code
        case @account_type
        when 'ordinary'
          '1'
        when 'checking'
          '2'
        when 'savings'
          '4'
        end
      end
    end
  end
end
