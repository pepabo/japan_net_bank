require 'spec_helper'
require 'japan_net_bank/transfer_csv/row'

describe JapanNetBank::TransferCsv::Row do
  let(:row_hash) {
    {
        bank_code:    '0123',
        branch_code:  '012',
        account_type: 'ordinary',
        number:       '0123456',
        name:         'キテコタロウ',
        amount:       1500,
    }
  }

  let(:row) { JapanNetBank::TransferCsv::Row.new(row_hash) }

  describe '#to_a' do
    it 'Row の内容が配列で返ってくる' do
      row_array = [
          JapanNetBank::TransferCsv::Row::RECORD_TYPE_DATA,
          '0123', '012', 'ordinary', '0123456', 'ｷﾃｺﾀﾛｳ'.encode('Shift_JIS'), '1500'
      ]

      expect(row.to_a).to eq row_array
    end
  end

  describe '#convert_to_hankaku_shift_jis' do
    it '半角カタカナ ShiftJIS に変換する' do
      expect(row.send(:convert_to_hankaku_shift_jis, 'キテコタロウ')).to eq 'ｷﾃｺﾀﾛｳ'.encode('Shift_JIS')
    end
  end
end
