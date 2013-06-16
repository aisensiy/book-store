# -*- encoding: utf-8 -*-

require "open-uri"
require "nokogiri"

def crawl(url)
  puts "get -- #{url}"
  page = Nokogiri::HTML(open(url))
  puts "title -- #{page.title}"
  book = {}
  book[:title] = page.css('#wrapper h1')[0].text.strip()
  el = page.search "[text()*='作者']"
  puts el
end

crawl('http://book.douban.com/subject/10779534/')
