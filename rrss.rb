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
opt = {}
opt['User-Agent'] = 'Opera/9.80 (Windows NT 5.1; U; ja) Presto/2.7.62 Version/11.01 '

get '/rss/' do 
  "active"
end

not_found do
  "not found"
end

error do
  "sorry"
end

get '/rss/shuffle' do 
  while true
    sleep(0.2)
    ago = (Date.today-Date.parse(start)).to_i - rand(3600) #古い物を少なく
    day = Date.today - (rand(ago)+1)
    url = "http://b.hatena.ne.jp/#{user}/rss?date=#{day.strftime("%Y%m%d")}"
    puts url
    
    open(url,opt) do |http|
      doc = http.read
      xml = REXML::Document.new(doc)
      next if REXML::XPath.match(xml,'//item').empty? #中身無ければ読込直し

      rss = RSS::Parser.parse(doc,false)
      rss = RSS::Maker.make("2.0") do |m|
        m.channel.title = "はてブ棚卸 shuffle"
        m.channel.description = "はてブ棚卸 shuffle"
        m.channel.link = "http://b.hatena.ne.jp/#{user}"
        rss.items.each do |i|
          m.items.new_item do |item|
            item.link = i.link
            item.title = i.title
            item.description = i.description
            item.date = Time.now
            item.content_encoded = i.date.to_s+" "+i.content_encoded
            puts item.content_encoded
            item.dc_subject = i.dc_subject
          end
        end
      end
      return rss.to_s
    end
  end
end

get '/rss/:tag/:date' do |tag,date|
  day = Date.today - date.to_i
  url = "http://b.hatena.ne.jp/#{user}/rss?date=#{day.strftime("%Y%m%d")}"
  txt = "はてブ棚卸 #{date}日前"
  txt += " タグ:#{tag}" unless tag == "all"

  open(url,opt) do |http|
    doc = http.read
    xml = REXML::Document.new(doc)
    rss = RSS::Parser.parse(doc,false)
    exist = false
    rss = RSS::Maker.make("1.0") do |m|
      m.channel.title = txt
      m.channel.description = txt
      m.channel.about = rss.channel.about
      m.channel.link = rss.channel.link
      rss.items.each do |i|
        if tag == "all" or tag == i.dc_subject 
          exist = true
          m.items.new_item do |item|
            item.link = i.link
            item.title = i.title
            item.description = i.description
            item.date = i.date
            item.content_encoded = i.content_encoded
            item.dc_subject = i.dc_subject
          end
        end
      end
      empty(m) unless exist #タグで絞ると項目が無くなる場合
    end
    return rss.to_s
  end
end

def empty(m)
  m.items.new_item do |item|
    item.link = "http://b.hatena.ne.jp/"
    item.title = "No entry"
    item.description = "No entry"
  end
end


