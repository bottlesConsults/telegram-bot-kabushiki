TOKEN = ENV['TOKEN']
BOT_NAME = ENV['BOT_NAME']

TIMEOUT = 60 # 1 minute
WATCH_USERS_LIMIT = 5
WATCH_STOCKS_LIMIT = 10

CHART_PATH = 'http://chart.finance.yahoo.com/z?'.freeze
PRICE_PATH = 'http://download.finance.yahoo.com/d/quotes.csv?'.freeze
NEWS_PATH = 'https://feeds.finance.yahoo.com/rss/2.0/headline?'.freeze
CURRENCY_PATH = './data/currency.csv'.freeze
STOCK_PATH = './data/stock.csv'.freeze
WATCH_PATH = './data/watch.yaml'.freeze
CHART_IMAGE_PATH = './tmp/chart.jpg'.freeze
LOG_PATH = './tmp/errors.log'.freeze

# Refer to the links for more emoji
# http://apps.timwhitlock.info/emoji/tables/unicode
# https://github.com/AxeLFFF/telegram-mems-bot/tree/master/telegram
class Emoji
  FACE_THROWING_A_KISS = "\xF0\x9F\x98\x98".freeze
  OK_HAND_SIGN = "\xF0\x9F\x91\x8C".freeze
  CHART_WITH_UPWARDS_TREND = "\xF0\x9F\x93\x88".freeze
  CHART_WITH_DOWNWARDS_TREND = "\xF0\x9F\x93\x89".freeze
  FACE_WITH_NO_GOOD_GESTURE = "\xF0\x9F\x99\x85".freeze
  HEAVY_MINUS_SIGN = "\xE2\x9E\x96".freeze
  SEE_NO_EVIL_MONKEY = "\xF0\x9F\x99\x88".freeze
  HEAR_NO_EVIL_MONKEY = "\xF0\x9F\x99\x89".freeze
  SPEAK_NO_EVIL_MONKEY = "\xF0\x9F\x99\x8A".freeze
  MONKEYS = SEE_NO_EVIL_MONKEY + HEAR_NO_EVIL_MONKEY + SPEAK_NO_EVIL_MONKEY

  def self.trend(value)
    if value > 0
      CHART_WITH_UPWARDS_TREND
    elsif value < 0
      CHART_WITH_DOWNWARDS_TREND
    else
      HEAVY_MINUS_SIGN
    end
  end
end

COMMAND = { start:
                    { valid_param: false },
            help:
                    { valid_param: false },
            list:
                    { valid_param: false, msg: { parse_mode: 'HTML' } },
            stock:
                    { valid_param: true, msg: { parse_mode: 'HTML' } },
            rate:
                    { valid_param: true, msg: { parse_mode: 'HTML' } },
            charts:
                    { valid_param: true, photo: true, msg: { parse_mode: 'HTML' } },
            stat:
                    { valid_param: true, photo: true, msg: { parse_mode: 'HTML', disable_web_page_preview: true } },
            watch:
                    { valid_param: true, authenticate: true, msg: {} },
            unwatch:
                    { valid_param: true, authenticate: true, msg: {} },
            watch_clear:
                    { valid_param: false, authenticate: true, msg: {} },
            watch_list:
                    { valid_param: false, authenticate: true, msg: {} }
        }.freeze
