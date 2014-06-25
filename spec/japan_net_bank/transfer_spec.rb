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

  describe 'self.fee_for' do
    context 'ジャパンネット銀行への振込のとき' do
      it '振込手数料を取得できる' do
        transfer_fee = JapanNetBank::Transfer.fee_for(bank_code: JapanNetBank::BANK_CODE, credit: 3200)
        expect(transfer_fee).to eq JapanNetBank::Transfer::FEE_TO_JAPAN_NET_BANK
      end
    end

    context 'ジャパンネット銀行以外への振込のとき' do
      context '30,000円未満の振込のとき' do
        it '振込手数料を取得できる' do
          transfer_fee = JapanNetBank::Transfer.fee_for(bank_code: '0123', credit: 29_999)
          expect(transfer_fee).to eq JapanNetBank::Transfer::FEE_FOR_CREDIT_UNDER_30_000
        end
      end

      context '30,000円以上の振込のとき' do
        it '振込手数料を取得できる' do
          transfer_fee = JapanNetBank::Transfer.fee_for(bank_code: '0123', credit: 30_000)
          expect(transfer_fee).to eq JapanNetBank::Transfer::FEE_FOR_CREDIT_AND_OVER_30_000
        end
      end
    end
  end

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

  describe '#to_csv' do
    it 'CSV 文字列を取得できる' do
      csv_row1 = JapanNetBank::Transfer::Row.new(row_hash1).to_a.join(',')
      csv_row2 = JapanNetBank::Transfer::Row.new(row_hash2).to_a.join(',')

      csv_trailer_row = [
          JapanNetBank::Transfer::Row::RECORD_TYPE_TRAILER,
          nil, nil, nil, nil, 2, 4800
      ].join(',')

      expect(transfer.to_csv).to eq csv_row1 + "\r\n" + csv_row2 + "\r\n" + csv_trailer_row + "\r\n"
    end
  end
end
