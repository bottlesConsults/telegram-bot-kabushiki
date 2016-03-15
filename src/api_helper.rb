require_relative 'constants'
require 'open-uri'
require 'nokogiri'
require 'uri'
require 'date'
require 'sanitize'

module ApiHelper
  FLAG = { 'NAME' => 'n',
           'SYMBOL' => 's',
           'LAST_TRADED_PRICE_ONLY' => 'l1',
           'YR_WEEK_RANGE' => 'w',
           'OPEN' => 'o',
           'PE' => 'r',
           'DIVIDEND' => 'd',
           'YEAR_HIGH' => 'k',
           'YEAR_LOW' => 'j',
           'BOOK_VALUE' => 'b4'
        }.freeze
  PRICE_FLAGS = FLAG['NAME'] + FLAG['SYMBOL'] + FLAG['LAST_TRADED_PRICE_ONLY']
  STAT_FLAGS = FLAG['NAME'] + FLAG['SYMBOL'] + FLAG['LAST_TRADED_PRICE_ONLY'] + FLAG['PE'] + FLAG['DIVIDEND']

  def get_chart(params)
    query = params.include?(',') ? "%5ESTI&c=#{params}" : params

    open(CHART_IMAGE_PATH, 'wb') do |file|
      file << open("#{CHART_PATH}s=#{query}&z=l").read
    end
    true
  end

  def get_preview(params)
    "#{CHART_PATH}s=#{params}"
  end

  def get_price(params)
    file = open("#{PRICE_PATH}s=#{params}&f=#{PRICE_FLAGS}.csv").read
    result = {}
    if file[/\d/] && !file.start_with?('N/A')
      CSV.parse(file).each do |row|
        change = row[4].split(' ')
        result[row[1]] = { name: row[0], amount: row[2], change_amount: change[0], change_percent: change[2] }
      end
    end
    result
  end

  def get_stat(params)
    breakdown = get_breakdown(params)
    news = get_news(params)
    if breakdown.empty?
      {}
    else
      breakdown[params].merge!(news[params])
      breakdown
    end
  end

  def get_breakdown(params)
    file = open("#{PRICE_PATH}s=#{params}&f=#{STAT_FLAGS}.csv").read

    result = {}
    if file [/\d/] && !file.start_with?('N/A')
      CSV.parse(file).each do |row|
        result[row[1]] = parse_breakdown(row)
      end
    end
    result
  end

  def get_news(params)
    doc = Nokogiri::XML(open("#{NEWS_PATH}s=#{params}&region=US&lang=en-US"))

    result = []
    doc.xpath('//item').each_with_index do |item, index|
      break if index > 2
      unless item.css('title').text.include?('Yahoo! Finance: RSS feed not found')
        result << parse_news(item)
      end
    end
    { params => { news: result } }
  end

  def get_currency(params)
    file = open("#{PRICE_PATH}s=#{params}=x&f=#{PRICE_FLAGS}.csv").read

    result = {}
    if file[/\d/] && !file.start_with?('N/A')
      CSV.parse(file).each do |row|
        result[params.to_s] = parse_currency(row)
      end
    end
    result
  end

  private

  def parse_breakdown(row)
    change = row[6].split(' ')
    { name: row[0], amount: row[2], change_amount: change[0], change_percent: change[2], volume: row[8],
      dividend: row[4], pe: row[3] }
  end

  def parse_currency(row)
    codes = row[0].split('/')
    change = row[4].split(' ')
    { from_code: codes[0], to_code: codes[1], amount: row[2], change_amount: change[0], change_percent: change[2] }
  end

  def parse_news(item)
    date = DateTime.httpdate(item.css('pubDate').text)
    { title: Sanitize.fragment(item.css('title').text), url: item.css('link').text.split('/*')[1],
      date: date.strftime('%d %b %Y %H:%M:%S GMT') }
  end
end
