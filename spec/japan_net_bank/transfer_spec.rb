require 'spec_helper'
require 'japan_net_bank/transfer'

describe JapanNetBank::Transfer do
  let(:transfer) { JapanNetBank::Transfer.new }

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

  describe '#generate' do
    context '振込データが正しいとき' do
      it 'CSV 文字列を生成できる' do
        csv_string = transfer.generate do
          transfer << row_hash1
          transfer << row_hash2
        end

        csv_row1 = JapanNetBank::Transfer::Row.new(row_hash1).to_a.join(',')
        csv_row2 = JapanNetBank::Transfer::Row.new(row_hash2).to_a.join(',')

        trailer_row = [
            JapanNetBank::Transfer::Row::RECORD_TYPE_TRAILER,
            nil, nil, nil, nil, 2, 4800
        ].join(',')

        expect(csv_string).to eq csv_row1 + "\r\n" + csv_row2 + "\r\n" + trailer_row + "\r\n"
      end
    end

    context '振込データに誤りがあるとき' do
      let(:invalid_row_hash) {
        {
            bank_code:    '012',
            branch_code:  '01',
            account_type: 'invalid',
            number:       '012345',
            name:         '',
            amount:       1.5,
        }
      }

      it 'ArgumentError が発生する' do
        expect {
          transfer.generate do
            transfer << invalid_row_hash
          end
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#rows_count' do
    before do
      transfer.generate do
        transfer << row_hash1
        transfer << row_hash2
      end
    end

    it 'レコード数を取得できる' do
      expect(transfer.rows_count).to eq 2
    end
  end

  describe '#total_amount' do
    before do
      transfer.generate do
        transfer << row_hash1
        transfer << row_hash2
      end
    end

    it '振込金額の合計を取得できる' do
      expect(transfer.total_amount).to eq 4800
    end
  end
end
