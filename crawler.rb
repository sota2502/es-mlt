require 'faraday'
require 'nokogiri'
require 'json'

def extract_item(category, url)
  res = Faraday.get(url)
  return unless res.success?

  html = Nokogiri::HTML.parse(res.body)

  {
    category:,
    title: html.search('article header h1').first.text,
    body: html.search('div.article_body').first.text,
  }
rescue => e
  puts url
  raise e
end

def extract_urls(index_url)
  res = Faraday.get(index_url)
  html = Nokogiri::HTML.parse(res.body)
  html.search('li.newsFeed_item').map do |li|
    content_id = li.attr('data-ual').match(/content_id:([^;]+)/)[1]
    "https://news.yahoo.co.jp/articles/#{content_id}"
  end
end

CATEGORIES = %w[
  business
  entertainment
  sports
  it
  science
]

File.open('bulk.json', 'w') do |file|
  CATEGORIES.each do |category|
    (1..5).each do |page|
      urls = extract_urls("https://news.yahoo.co.jp/topics/#{category}?page=#{page}")
      urls.each do |url|
        data = extract_item(category, url)
        next if data.nil?

        file.puts('{"index":{}}')
        file.puts(JSON.generate(data))
      end
    end
  end
end
