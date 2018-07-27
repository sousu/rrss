
## RRSS

RubyではてブRSS再配信して棚卸し

 - はてブの過去登録を振り返るためのRSSを配信
 - 特定期間前（3日前・1ヶ月前…）／特定タグをURLで指定

### 使い方

起動

    ruby rrss.rb [user-id]

RSSの登録

    http://path/to/sinatra/all/365  1年前の全てのはてブ
    http://path/to/sinatra/@de/3    3日目のタグ[@de]のはてブ
    
