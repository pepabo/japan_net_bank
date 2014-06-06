require 'spec_helper'
require 'japan_net_bank/transfer_csv/row'

describe JapanNetBank::TransferCsv::Row do
  let(:row_hash) {
    {
        bank_code:    '0123',
        branch_code:  '012',
        account_type: 'ordinary',
        number:       '0123456',
        name:         'サトウキテコ',
        amount:       1600,
    }
  }

  let(:row) { JapanNetBank::TransferCsv::Row.new(row_hash) }

  describe 'attributes' do
    describe 'bank_code' do
      context '4桁の数字のとき' do
        it 'エラーが発生しない' do
          row.bank_code = '0123'
          expect(row).to be_valid
        end
      end

      context '3桁の数字のとき' do
        it 'エラーが発生する' do
          row.bank_code = '012'
          expect(row).not_to be_valid
          expect(row.errors[:bank_code]).to be_present
        end
      end

      context '4桁のアルファベットのとき' do
        it 'エラーが発生する' do
          row.bank_code = 'abcd'
          expect(row).not_to be_valid
          expect(row.errors[:bank_code]).to be_present
        end
      end
    end

    describe 'branch_code' do
      context '3桁の数字のとき' do
        it 'エラーが発生しない' do
          row.branch_code = '012'
          expect(row).to be_valid
        end
      end

      context '2桁の数字のとき' do
        it 'エラーが発生する' do
          row.branch_code = '01'
          expect(row).not_to be_valid
          expect(row.errors[:branch_code]).to be_present
        end
      end

      context '3桁のアルファベットのとき' do
        it 'エラーが発生する' do
          row.branch_code = 'abc'
          expect(row).not_to be_valid
          expect(row.errors[:branch_code]).to be_present
        end
      end
    end
  end

  describe '#to_a' do
    it 'Row の内容が配列で返ってくる' do
      row_array = [
          JapanNetBank::TransferCsv::Row::RECORD_TYPE_DATA,
          '0123', '012', '1', '0123456', 'ｻﾄｳｷﾃｺ'.encode('Shift_JIS'), '1600'
      ]

      expect(row.to_a).to eq row_array
    end
  end

  describe '#convert_to_hankaku_katakana' do
    it '半角カタカナに変換する' do
      expect(row.send(:convert_to_hankaku_katakana, 'サトウキテコ')).to eq 'ｻﾄｳｷﾃｺ'
    end
  end
end
