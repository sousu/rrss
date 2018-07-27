#
# RRSS: RubyではてブRSS再配信
#

require 'sinatra'
require 'sinatra/reloader'
require 'date'
require 'open-uri'
require 'rss'
require 'rexml/document'

if ARGV[0]
  user = ARGV[0]
else
  puts "set user"
  exit
end

set :show_exceptions, false
opt = {}
opt['User-Agent'] = 'Opera/9.80 (Windows NT 5.1; U; ja) Presto/2.7.62 Version/11.01 '

get '/rss/' do 
  "active"
end

get '/rss/:tag/:date' do |tag,date|
  d = Date.today - date.to_i
  url = "http://b.hatena.ne.jp/#{user}/rss?date=#{d.strftime("%Y%m%d")}"

  open(url,opt) do |http|
    doc = http.read
    txt = "はてブ棚卸 #{date}日前"
    txt += " タグ:#{tag}" if not tag == "all"
    rss = RSS::Parser.parse(doc,false)

    xml = REXML::Document.new(doc)
    if REXML::XPath.match(xml,'//item').empty?
      return RSS::Maker.make("1.0") do |m|
        m.channel.title = txt
        m.channel.description = txt
        m.channel.about = rss.channel.about
        m.channel.link = rss.channel.link
        empty(m)
      end.to_s
    end

    if tag != "all"
      exist = false
      return RSS::Maker.make("1.0") do |m|
        m.channel.title = txt
        m.channel.description = txt
        m.channel.about = rss.channel.about
        m.channel.link = rss.channel.link
        rss.items.each do |i|
          if /user-tag.+#{tag}/ =~ i.content_encoded 
            exist = true
            m.items.new_item do |item|
              item.link = i.link
              item.title = i.title
              item.description = i.description
              item.date = i.date
              item.content_encoded = i.content_encoded
            end
          end
        end
        empty(m) unless exist
      end.to_s
    end

    rss.channel.title = txt
    rss.channel.description = txt
    rss.to_s
  end
end

def empty(m)
  m.items.new_item do |item|
    item.link = "http://sousu.jp/"
    item.title = "No entry"
    item.description = "No entry"
  end
end


