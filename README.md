
## rrss

RubyではてブRSS再配信して棚卸し

 - はてブの過去登録を振り返るためのRSSを配信
 - 特定期間前（3日前・1ヶ月前…）／特定タグをURLで指定

### 使い方

起動

    rrss.rb [user_id] [start_date Ex:2006-07-26]

RSSの登録

    http://path/to/sinatra/rss/all/365       1年前の全てのはてブ取得
    http://path/to/sinatra/rss/@de/3         3日目のタグ[@de]のはてブ取得
    http://path/to/sinatra/rss/all/shuffle   全てからのランダム取得
    http://path/to/sinatra/rss/tabe/shuffle  タグ[tabe]からのランダム取得
    
