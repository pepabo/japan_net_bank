require 'spec_helper'
require 'japan_net_bank/transfer/row'

describe JapanNetBank::Transfer::Row do
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

  let(:row) { JapanNetBank::Transfer::Row.new(row_hash) }

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

    describe 'account_type' do
      context 'ordinary, checking, savings のいずれかのとき' do
        it 'エラーが発生しない' do
          %w(ordinary checking savings).each do |type|
            row.account_type = type
            expect(row).to be_valid
          end
        end
      end

      context 'ordinary, checking, savings の以外のとき' do
        it 'エラーが発生する' do
          row.account_type = 'invalid_account_type'
          expect(row).not_to be_valid
          expect(row.errors[:account_type]).to be_present
        end
      end
    end

    describe 'number' do
      context '7桁の数字のとき' do
        it 'エラーが発生しない' do
          row.number = '0123456'
          expect(row).to be_valid
        end
      end

      context '6桁の数字のとき' do
        it 'エラーが発生する' do
          row.number = '012345'
          expect(row).not_to be_valid
          expect(row.errors[:number]).to be_present
        end
      end

      context '7桁のアルファベットのとき' do
        it 'エラーが発生する' do
          row.number = 'abcdefg'
          expect(row).not_to be_valid
          expect(row.errors[:number]).to be_present
        end
      end
    end

    describe 'name' do
      context '存在するとき' do
        it 'エラーが発生しない' do
          row.name = 'サトウキテコ'
          expect(row).to be_valid
        end
      end

      context '空文字列のとき' do
        it 'エラーが発生する' do
          row.name = ''
          expect(row).not_to be_valid
          expect(row.errors[:name]).to be_present
        end
      end
    end

    describe 'amount' do
      context '1以上の整数のとき' do
        it 'エラーが発生しない' do
          row.amount = 1
          expect(row).to be_valid
        end
      end

      context '0 とき' do
        it 'エラーが発生する' do
          row.amount = 0
          expect(row).not_to be_valid
          expect(row.errors[:amount]).to be_present
        end
      end

      context '小数とき' do
        it 'エラーが発生する' do
          row.amount = 1.5
          expect(row).not_to be_valid
          expect(row.errors[:amount]).to be_present
        end
      end
    end
  end

  describe '#to_a' do
    it 'Row の内容が配列で返ってくる' do
      row_array = [
          JapanNetBank::Transfer::Row::RECORD_TYPE_DATA,
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

  describe '#==' do
    let(:other_row) { JapanNetBank::Transfer::Row.new(row_hash) }

    context '同じ内容の振込データのとき' do
      it 'trueが返る' do
        expect(row).to eq other_row
      end
    end

    context '振込額が異なるとき' do
      before do
        other_row.amount = row.amount-1
      end

      it 'falseが返る' do
        expect(row).not_to eq other_row
      end
    end
  end
end
