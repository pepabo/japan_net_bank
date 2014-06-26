require 'nkf'
require 'active_model'

module JapanNetBank
  class Transfer
    class TrailerRow
      include ActiveModel::Validations

      attr_accessor :record_type, :rows_count, :total_amount

      RECORD_TYPE = '2'

      validates :rows_count, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
      validates :total_amount, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

      def initialize(record_type: RECORD_TYPE, rows_count: nil, total_amount: nil)
        @record_type  = record_type
        @rows_count   = rows_count.to_i
        @total_amount = total_amount.to_i

        raise ArgumentError, errors.full_messages unless valid?
      end

      def to_a
        [@record_type, nil, nil, nil, nil, @rows_count, @total_amount]
      end
    end
  end
end
