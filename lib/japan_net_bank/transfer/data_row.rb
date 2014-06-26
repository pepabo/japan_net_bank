require 'nkf'
require 'active_model'

module JapanNetBank
  class Transfer
    class DataRow
      include ActiveModel::Validations

      attr_accessor :record_type, :bank_code, :branch_code, :account_type, :number, :name, :amount

      RECORD_TYPE   = '1'
      ACCOUNT_TYPES = { '1' => 'ordinary', '2' => 'checking', '4' => 'savings' }

      validates :bank_code, format: { with: /\A\d{4}\z/ }
      validates :branch_code, format: { with: /\A\d{3}\z/ }
      validates :account_type, inclusion: { in: %w(ordinary checking savings) }
      validates :number, format: { with: /\A\d{7}\z/ }
      validates :name, presence: true
      validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

      def initialize(record_type: RECORD_TYPE, bank_code: nil, branch_code: nil, account_type: nil, number: nil, name: nil, amount: nil)
        @record_type  = record_type
        @bank_code    = bank_code
        @branch_code  = branch_code
        @account_type = account_type
        @number       = number
        @name         = name
        @amount       = amount

        raise ArgumentError, errors.full_messages unless valid?
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
