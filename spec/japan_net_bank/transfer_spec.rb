require 'spec_helper'
require 'japan_net_bank/transfer'

describe JapanNetBank::Transfer do
  let(:row_hash1) {
    {
        bank_code:    '0123',
        branch_code:  '012',
        account_type: 'ordinary',
        number:       '0123456',
        name:         'サトウキテコ',
        amount:       1600,
    }
  }

  let(:row_hash2) {
    {
        bank_code:    '0123',
        branch_code:  '012',
        account_type: 'ordinary',
        number:       '0123456',
        name:         'サトウハナコ',
        amount:       3200,
    }
  }

  let(:rows) { [row_hash1, row_hash2] }
  let(:transfer) { JapanNetBank::Transfer.new(rows) }

  describe '#initialize' do
    context '振込データが正しいとき' do
      it 'トレーラー行が追加されたデータを生成できる' do
        row1 = JapanNetBank::Transfer::Row.new(row_hash1).to_a
        row2 = JapanNetBank::Transfer::Row.new(row_hash2).to_a

        trailer_row = [
            JapanNetBank::Transfer::Row::RECORD_TYPE_TRAILER,
            nil, nil, nil, nil, 2, 4800
        ]

        expect(transfer.rows).to eq [row1, row2, trailer_row]
      end
    end

    context '振込データのフォーマットに誤りがあるとき' do
      let(:invalid_row_hash) {
        {
            bank_code:    '012',
            branch_code:  '01',
            account_type: 'invalid',
            number:       '012345',
            # name: を削除している
            amount:       1.5,
        }
      }

      it 'ArgumentError が発生する' do
        expect {
          JapanNetBank::Transfer.new([invalid_row_hash])
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#rows_count' do
    it 'レコード数を取得できる' do
      expect(transfer.rows_count).to eq 2
    end
  end

  describe '#total_amount' do
    it '振込金額の合計を取得できる' do
      expect(transfer.total_amount).to eq 4800
    end
  end
end
