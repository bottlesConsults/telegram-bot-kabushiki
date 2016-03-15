require 'telegram/bot'
require './src/constants'
require './src/command_handler'

namespace :bot do
  desc 'send stock info'
  task :push do
    Telegram::Bot::Client.run(TOKEN) do |bot|
      command = CommandHandler.new

      WatchParser.new(WATCH_PATH).list.each_pair do |key, value|
        param = value.map { |val| command.stock(param: val) }
        if param
          result = "you are receiving auto notification \n\n"
          result << param.join('')
        else
          result = "you are not watching any stock\n"
        end
        result << "\n refer to /help for instruction on watching"
        bot.api.send_message(chat_id: key, text: result, parse_mode: 'HTML')
      end
    end
  end
end
