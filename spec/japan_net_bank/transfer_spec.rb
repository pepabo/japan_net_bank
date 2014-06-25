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
  let(:transfer_data) { File.read('spec/files/sample_jnb.csv') } # Shift_JIS

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

  describe 'self.parse_csv' do
    it 'CSV データを読み込むことができる'
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

  describe '#encode_to_utf8' do
    context 'Shift_JIS の文字列を渡したとき' do
      it 'UTF-8 の文字列を取得できる（全角カタカナ）' do
        expect(transfer.send(:encode_to_utf8, transfer_data)).to match 'ニホンシヨウジ'
      end
    end

    context '既に UTF-8 に変換した文字列を渡したとき' do
      let(:utf8_string) { transfer_data.encode('UTF-8', 'Shift_JIS') }

      it 'UTF-8 の文字列を取得できる（全角カタカナ）' do
        expect(utf8_string).to match 'ﾆﾎﾝｼﾖｳｼﾞ'
        expect(transfer.send(:encode_to_utf8, utf8_string)).to match 'ニホンシヨウジ'
      end
    end
  end
end
