require_relative 'constants/constants'
require_relative 'parser/stock_parser'
require_relative 'parser/currency_parser'
require_relative 'parser/watch_parser'
require_relative 'api_helper'
require_relative 'format_helper'

class CommandHandler
  include FormatHelper
  include ApiHelper

  def initialize
    @currency = CurrencyParser.new(CURRENCY_PATH)
    @stock = StockParser.new(STOCK_PATH)
    @watch = WatchParser.new(WATCH_PATH)
  end

  def list(options = {})
    format(type: 'list', data: @stock.get_list(options[:param]))
  end

  def charts(options = {})
    ticker_hash = @stock.get_from_tags(options[:param])

    if ticker_hash && !ticker_hash.empty?
      param = ticker_hash.keys.join(',')
      get_chart(param)
      data = get_price(param)
      data.each_key { |key| data[key].merge!(ticker_hash[key]) }
      result = format(type: 'price', data: data)
    end

    result
  end

  def rate(options = {})
    param = @currency.validate_and_format(options[:param])
    result = format(type: 'currency', data: get_currency(param)) + get_preview(param.concat('=x')) if param
    result
  end

  def stat(options = {})
    # param = options[:param].upcase
    # ticker_hash = @stock.get_from_symbol(param)
    ticker_hash = @stock.get_from_symbol(options[:param])
    get_chart(options[:param])
    data = get_stat(options[:param])
    if data && !data.empty?
      data.each_key { |key| data[key].merge!(ticker_hash[key]) } unless ticker_hash.empty?
      result = format(type: 'stat', data: data)
    end

    result
  end

  def stock(options = {})
    param = options[:param]
    ticker_hash = @stock.get_from_symbol(param)
    ticker_hash = { param => {} } if ticker_hash.empty?
    data = get_price(ticker_hash.keys.join(','))

    unless data.empty?
      data = data.each_key { |key| data[key].merge!(ticker_hash[key]) }
      result = format(type: 'price', data: data)
    end

    result
  end

  def stocks(options = {})
    param = options[:param]
    ticker_hash = param.each_key { |key| @stock.get_from_symbol(key) || { key => {} } }
    data = get_price(ticker_hash.keys.join(','))

    unless data.empty?
      data = data.each_key { |key| data[key].merge!(ticker_hash[key]) }
      result = format(type: 'price', data: data)
    end

    result
  end

  def watch(options = {})
    p 'watching'
    p user
    p param
    @watch.add(options[:user], options[:param])
  end

  def unwatch(options = {})
    p 'unwatching'
    p user
    p param
    @watch.remove(options[:user], options[:param])
  end

  def watch_list(options = {})
    p 'watch list'
    p user
    @watch.list[options[:user]]
  end

  def watch_clear(options = {})
    p 'watch clear'
    p user
    @watch.remove(options[:user], options[:param])
  end
end
