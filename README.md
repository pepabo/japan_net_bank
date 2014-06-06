# JapanNetBank

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'japan_net_bank'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install japan_net_bank

## Usage

```ruby
transfer_data1 = {
    bank_code:    '0123',
    branch_code:  '012',
    account_type: 'ordinary',
    number:       '0123456',
    name:         'サトウキテコ',
    amount:       1600,
}

transfer_data2 = {
    bank_code:    '0999',
    branch_code:  '099',
    account_type: 'ordinary',
    number:       '0999999',
    name:         'サトウハナコ',
    amount:       3200,
}

transfer_csv = JapanNetBank::TransferCsv.generate do |csv|
  [transfer_data1, transfer_data2].each do |transfer_data|
    csv << transfer_data
  end
end

puts transfer_csv #=> "1,0123,012,1,0123456,ｻﾄｳｷﾃｺ,1600\r\n1,0999,099,1,0999999,ｻﾄｳﾊﾅｺ,3200\r\n2,,,,,2,4800\r\n"
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/japan_net_bank/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
