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

また、下記に基づいて振込手数料を算出できます。

* http://www.japannetbank.co.jp/web_all_baplus_manual.pdf
* 現在、組戻手数料には対応していません
* 手数料の変更には追随していく方針ですが、追随が遅れる可能性があります

## Installation

Add this line to your application's Gemfile:

    gem 'japan_net_bank'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install japan_net_bank

## Usage

### 振込用 CSV を生成

```ruby
transfer_data = [
    {
        bank_code:    '0123',
        branch_code:  '012',
        account_type: 'ordinary', # ordinary / checking / savings
        number:       '0123456',
        name:         'サトウキテコ',
        amount:       1600,
    },
    {
        bank_code:    '0999',
        branch_code:  '099',
        account_type: 'ordinary',
        number:       '0999999',
        name:         'サトウハナコ',
        amount:       3200,
    }
]

csv_string = JapanNetBank::Transfer.new(transfer_data).to_csv
# or csv_string = JNB::Transfer.new(transfer_data).to_csv

puts csv_string #=> "1,0123,012,1,0123456,ｻﾄｳｷﾃｺ,1600\r\n1,0999,099,1,0999999,ｻﾄｳﾊﾅｺ,3200\r\n2,,,,,2,4800\r\n"
```

### 振込手数料を算出

```ruby
transfer_fee = JapanNetBank::Transfer.fee_for(bank_code: '0123', amount: 30_000)
# or JNB::Transfer.fee_for(bank_code: '0123', amount: 30_000)

puts transfer_fee #=> 270
```
