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
  let(:transfer) { JapanNetBank::Transfer.generate(rows) }
  let(:transfer_data) { File.read('spec/files/sample_jnb.csv') } # Shift_JIS

  describe 'self.generate' do
    context '振込データが正しいとき' do
      it 'データ行とトレーラー行が追加されたデータを生成できる' do
        row1        = transfer.rows.find { |row| row.record_type == JapanNetBank::Transfer::Row::RECORD_TYPE_DATA }
        trailer_row = transfer.rows.find { |row| row.record_type == JapanNetBank::Transfer::TrailerRow::RECORD_TYPE }

        expect(row1.bank_code).to eq '0123'
        expect(row1.branch_code).to eq '012'
        expect(row1.account_type).to eq 'ordinary'
        expect(row1.number).to eq '0123456'
        expect(row1.name).to eq 'サトウキテコ'
        expect(row1.amount).to eq 1600

        expect(trailer_row.rows_count).to eq 2
        expect(trailer_row.total_amount).to eq 4800
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
          JapanNetBank::Transfer.generate([invalid_row_hash])
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'self.parse_csv' do
    it 'CSV データを読み込むことができる' do
      transfer_row = JapanNetBank::Transfer.parse_csv(transfer_data).rows.first

      expect(transfer_row.record_type).to eq '1'
      expect(transfer_row.bank_code).to eq '0033'
      expect(transfer_row.branch_code).to eq '001'
      expect(transfer_row.account_type).to eq 'ordinary'
      expect(transfer_row.number).to eq '1111111'
      expect(transfer_row.name).to eq 'カ)ニホンシヨウジ'
      expect(transfer_row.amount).to eq '1000'
    end
  end

  describe 'self.encode_to_utf8' do
    context 'Shift_JIS の文字列を渡したとき' do
      it 'UTF-8 の文字列を取得できる（全角カタカナ）' do
        expect(JapanNetBank::Transfer.send(:encode_to_utf8, transfer_data)).to match 'カ\)ニホンシヨウジ'
      end
    end

    context '既に UTF-8 に変換した文字列を渡したとき' do
      let(:utf8_string) { transfer_data.encode('UTF-8', 'Shift_JIS') }

      it 'UTF-8 の文字列を取得できる（全角カタカナ）' do
        expect(utf8_string).to match /ｶ\)ﾆﾎﾝｼﾖｳｼﾞ/
        expect(JapanNetBank::Transfer.send(:encode_to_utf8, utf8_string)).to match 'カ\)ニホンシヨウジ'
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
