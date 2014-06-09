require 'spec_helper'

describe JapanNetBank do
  it 'should have a version number' do
    expect(JapanNetBank::VERSION).not_to eq be_nil
  end

  it 'JNB でもアクセスできる' do
    rows = [
        {
            bank_code:    '0123',
            branch_code:  '012',
            account_type: 'ordinary',
            number:       '0123456',
            name:         'サトウキテコ',
            amount:       1600,
        }
    ]

    expect {
      JNB::Transfer.new(rows).to_csv
    }.not_to raise_error
  end
end
