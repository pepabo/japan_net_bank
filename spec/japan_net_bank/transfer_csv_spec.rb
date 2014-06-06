require 'spec_helper'
require 'japan_net_bank/transfer_csv'

describe JapanNetBank::TransferCsv do
  describe 'self.generate' do
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

    context '振込データが正しいとき' do
      it 'CSV 文字列を生成できる' do
        transfer_csv = JapanNetBank::TransferCsv.generate do |csv|
          csv << row_hash1
          csv << row_hash2
        end

        csv_row1 = JapanNetBank::TransferCsv::Row.new(row_hash1).to_a.join(',')
        csv_row2 = JapanNetBank::TransferCsv::Row.new(row_hash2).to_a.join(',')

        trailer_row = [
            JapanNetBank::TransferCsv::Row::RECORD_TYPE_TRAILER,
            nil, nil, nil, nil, 2, 4800
        ].join(',')

        expect(transfer_csv).to eq csv_row1 + "\r\n" + csv_row2 + "\r\n" + trailer_row + "\r\n"
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
          JapanNetBank::TransferCsv.generate do |csv|
            csv << invalid_row_hash
          end
        }.to raise_error(ArgumentError)
      end
    end
  end
end