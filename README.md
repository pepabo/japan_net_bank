# JapanNetBank

ジャパンネット銀行の振込用 CSV を生成処理をサポートするライブラリです。

（サンプル CSV）

```csv
1,33,1,1,1111111,ｶ)ﾆﾎﾝｼﾖｳｼﾞ,1000,ｼﾞﾔﾊﾟﾈﾀﾛｳ
1,33,1,1,2222222,ｶ)ﾔﾏﾓﾄｼﾖｳﾃﾝ,1000,ｼﾞﾔﾊﾟﾈﾀﾛｳ
1,33,1,1,3333333,ﾆﾎﾝｺｳｷﾞﾖｳ(ｶ,1000,ｼﾞﾔﾊﾟﾈﾀﾛｳ
1,33,1,1,4444444,ｻｻｷｼﾖｳｶｲ(ｶ,1000,ｼﾞﾔﾊﾟﾈﾀﾛｳ
1,33,1,1,5555555,ｶﾄｳﾊﾅｺ,1000,ｼﾞﾔﾊﾟﾈﾀﾛｳ
1,33,1,1,6666666,ｻﾄｳﾀﾛｳ,1000,ｼﾞﾔﾊﾟﾈﾀﾛｳ
1,33,1,1,7777777,ｻﾞｲ)ﾏﾙﾏﾙｷﾖｳｶｲ,1000,ｼﾞﾔﾊﾟﾈﾀﾛｳ
1,33,1,1,8888888,ｲ-.ﾏﾈ-（ｶ,1000,ｼﾞﾔﾊﾟﾈﾀﾛｳ
1,33,1,1,9999999,ｲｹﾀﾞ(ｶ)ﾆﾎﾝｼﾞﾑｼﾖ,1000,ｼﾞﾔﾊﾟﾈﾀﾛｳ
1,33,1,1,1234567,ﾐﾀﾌﾞﾝｸﾞﾃﾝ(ｶ,1000,ｼﾞﾔﾊﾟﾈﾀﾛｳ
2,,,,,10,10000,
```

振込用 CSV の詳細については下記を参照してください。

* [操作説明｜WEB総振｜BA-PLUSオプションサービス｜BA-PLUS｜ビジネスでのご利用｜ジャパンネット銀行](http://www.japannetbank.co.jp/business/baplus/service/web_all/manual.html)
* [csv_explain.pdf](http://www.japannetbank.co.jp/service/payment/web_all/csv_explain.pdf)

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
