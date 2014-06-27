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

  let(:row_hashes) { [row_hash1, row_hash2] }
  let(:transfer) { JapanNetBank::Transfer.from_hash_array(row_hashes) }
  let(:transfer_data) { File.read('spec/files/sample_jnb.csv') } # Shift_JIS

  describe 'self.from_hash_array' do
    context '正しい振込データが渡されたとき' do
      it 'データ行が追加されたデータを生成できる' do
        data_row1 = transfer.rows.first

        expect(data_row1.bank_code).to eq '0123'
        expect(data_row1.branch_code).to eq '012'
        expect(data_row1.account_type).to eq 'ordinary'
        expect(data_row1.number).to eq '0123456'
        expect(data_row1.name).to eq 'サトウキテコ'
        expect(data_row1.amount).to eq 1600

        expect(transfer.rows_count).to eq 2
        expect(transfer.total_amount).to eq 4800
      end
    end

    context 'フォーマットの誤った振込データが渡されたとき' do
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
          JapanNetBank::Transfer.from_hash_array([invalid_row_hash])
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'self.generate' do
    let(:row1) { JapanNetBank::Transfer::Row.new(row_hash1) }
    let(:row2) { JapanNetBank::Transfer::Row.new(row_hash2) }

    it 'Transfer#rows に Row オブジェクトが追加される' do
      transfer = JapanNetBank::Transfer.generate do |t|
        t << row1
        t << row2
      end

      data_row1 = transfer.rows.first

      expect(data_row1.bank_code).to eq '0123'
      expect(data_row1.branch_code).to eq '012'
      expect(data_row1.account_type).to eq 'ordinary'
      expect(data_row1.number).to eq '0123456'
      expect(data_row1.name).to eq 'サトウキテコ'
      expect(data_row1.amount).to eq 1600

      expect(transfer.rows_count).to eq 2
      expect(transfer.total_amount).to eq 4800
    end
  end

  describe 'self.parse_csv' do
    it 'CSV データを読み込むことができる' do
      row1 = JapanNetBank::Transfer.parse_csv(transfer_data).rows.first

      expect(row1.record_type).to eq '1'
      expect(row1.bank_code).to eq '0033'
      expect(row1.branch_code).to eq '001'
      expect(row1.account_type).to eq 'ordinary'
      expect(row1.number).to eq '1111111'
      expect(row1.name).to eq 'カ)ニホンシヨウジ'
      expect(row1.amount).to eq 1000
    end
  end

  describe 'self.fee_for' do
    context 'ジャパンネット銀行への振込のとき' do
      it '振込手数料を取得できる' do
        transfer_fee = JapanNetBank::Transfer.fee_for(bank_code: JapanNetBank::BANK_CODE, amount: 3200)
        expect(transfer_fee).to eq JapanNetBank::Transfer::FEE_TO_JAPAN_NET_BANK
      end
    end

    context 'ジャパンネット銀行以外への振込のとき' do
      context '30,000円未満の振込のとき' do
        it '振込手数料を取得できる' do
          transfer_fee = JapanNetBank::Transfer.fee_for(bank_code: '0123', amount: 29_999)
          expect(transfer_fee).to eq JapanNetBank::Transfer::FEE_FOR_AMOUNT_UNDER_30_000
        end
      end

      context '30,000円以上の振込のとき' do
        it '振込手数料を取得できる' do
          transfer_fee = JapanNetBank::Transfer.fee_for(bank_code: '0123', amount: 30_000)
          expect(transfer_fee).to eq JapanNetBank::Transfer::FEE_FOR_AMOUNT_AND_OVER_30_000
        end
      end
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
      row_array1        = JapanNetBank::Transfer::Row.new(row_hash1).to_a.join(',')
      row_array2        = JapanNetBank::Transfer::Row.new(row_hash2).to_a.join(',')
      trailer_row_array = [JapanNetBank::Transfer::Row::RECORD_TYPE_TRAILER, nil, nil, nil, nil, 2, 4800].join(',')

      expect(transfer.to_csv).to eq row_array1 + "\r\n" + row_array2 + "\r\n" + trailer_row_array + "\r\n"
    end
  end
end
