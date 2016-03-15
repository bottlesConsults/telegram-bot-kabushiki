require 'i18n'
require 'telegram/bot'
require_relative 'src/constants'
require_relative 'src/command_handler'

logger = Logger.new(LOG_PATH, Logger::DEBUG)
command = CommandHandler.new

I18n.load_path = Dir['config/locales.yml']
I18n.locale = :en
I18n.backend.load_translations

def stale?(time)
  DateTime.now.to_time.to_i - time > TIMEOUT
end

def group_chat?(message)
  message.chat.id != message.from.id
end

def ignore?(message, bot_name)
  stale?(message.date) || (group_chat?(message) && (bot_name != BOT_NAME))
end

def invalid_command?(cmd)
  !COMMAND.key?(cmd.to_sym)
end

def invalid_command_param?(cmd, param)
  COMMAND.dig(cmd.to_sym, :valid_param) && param.nil?
end

Telegram::Bot::Client.run(TOKEN, logger: logger) do |bot|
  bot.listen do |message|
    begin
      logger.info("#{message.from.first_name} of #{message.from.id},#{message.chat.id} says #{message.text}...")

      # process the params
      arg = message.text.split(' ')
      bot_name = arg[0].slice!(BOT_NAME)
      cmd = arg[0] ? arg[0][1..-1] : nil
      param = arg[1] && arg[1].match(/^[A-Za-z0-9.]+$/) ? arg[1].upcase : nil
      name = message.from.first_name

      # validation
      next if ignore?(message, bot_name)

      unless message.text
        bot.api.send_message(chat_id: message.chat.id, text: I18n.t('instruction'))
        next
      end

      if invalid_command?(cmd)
        bot.api.send_message(chat_id: message.chat.id,
                             text: I18n.t('invalid_command',
                                          emoji: Emoji::FACE_WITH_NO_GOOD_GESTURE,
                                          msg: arg[0]))
        next
      end

      if invalid_command_param?(cmd, param)
        bot.api.send_message(chat_id: message.chat.id,
                             text: I18n.t('invalid_param', name: name, emoji: Emoji::MONKEYS, msg: arg[1]))
        next
      end

      # grab data from api
      case cmd
      when 'help'
        bot.api.send_message(chat_id: message.chat.id,
                             text: I18n.t('instruction'))
      when 'start'
        bot.api.send_message(chat_id: message.chat.id,
                             text: I18n.t('welcome', name: name, emoji: Emoji::FACE_THROWING_A_KISS))
      else
        if command.respond_to?(cmd, param: param, user: message.chat.id)
          result = command.send(cmd, param: param, user: message.chat.id)

          if result && COMMAND.dig(cmd.to_sym, :photo)
            bot.api.send_photo(chat_id: message.chat.id, photo: File.new(CHART_IMAGE_PATH))
          end

          bot.api.send_message(chat_id: message.chat.id,
                               text: result || I18n.t('negative', name: name, param: param, cmd: cmd),
                               **COMMAND.dig(cmd.to_sym, :msg))
        end
      end
    rescue Exception => e
      logger.fatal(I18n.t('exception', name: message.from.first_name, id: message.from.id, msg: message.text, e: e))
    end
  end
end
