#
# RRSS: RubyではてブRSS再配信
#

require 'sinatra'
require 'date'
require 'open-uri'
require 'rss'
require 'rexml/document'

if ARGV.size >= 2
  user = ARGV[0]
  start = ARGV[1]
else
  puts "usage: rrss.rb [user_id] [start_date Ex:2006-07-26]"
  exit
end

set :show_exceptions, false
not_found do
  "not found"
end
error do
  "sorry"
end

get '/rss/' do 
  "active"
end
get '/rss/:tag/:date' do |tag,date|
  if date == "shuffle" 
    txt = "はてブ棚卸 shuffle"
    txt += " タグ:#{tag}" unless tag == "all"
    10.times do 
      sleep(0.5)
      ago = (Date.today-Date.parse(start)).to_i - rand(3600) #Todo 古い物を少なく
      day = Date.today - (rand(ago)+1)
      rss = open(day,txt,user,tag)
      return rss if rss
    end
    puts "cnt over"
    return nil
  else
    txt = "はてブ棚卸 #{date}日前"
    txt += " タグ:#{tag}" unless tag == "all"
    day = Date.today - date.to_i
    return open(day,txt,user,tag)
  end
end

def open(day,title,user,tag)
  opt = {}
  opt['User-Agent'] = 'Opera/9.80 (Windows NT 5.1; U; ja) Presto/2.7.62 Version/11.01 '
  url = "http://b.hatena.ne.jp/#{user}/rss?date=#{day.strftime("%Y%m%d")}"
  puts "open #{url}"
  URI.open(url,opt) do |http|
    nothing = true
    doc = http.read
    xml = REXML::Document.new(doc)
    return nil if REXML::XPath.match(xml,'//item').empty? #中身無しの場合
    rss = RSS::Parser.parse(doc,false)
    rss = RSS::Maker.make("2.0") do |m|
      m.channel.title = title
      m.channel.description = title
      m.channel.link = "https://b.hatena.ne.jp/#{user}"
      rss.items.each do |i|
        if tag == "all" or tag == i.dc_subject 
          nothing = false
          m.items.new_item do |item|
            item.link = i.link
            item.title = i.title
            item.description = i.description
            item.date = Time.now
            item.content_encoded = i.date.to_s+" "+i.content_encoded
            item.dc_subject = i.dc_subject
          end
        end
      end
      return nil if nothing #タグで絞ると項目が無くなる場合
    end
    return rss.to_s
  end
end

def empty(m)
  m.items.new_item do |item|
    item.link = "https://b.hatena.ne.jp/"
    item.title = "No entry"
    item.description = "No entry"
  end
end

