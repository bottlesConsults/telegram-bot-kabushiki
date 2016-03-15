#telegram-bot-kabushiki

WIP

A simple telegram bot to retrieve stock info from Yahoo API.
Kabushiki is a japanese word for stock market

Using the [telegram-bot-ruby](https://github.com/atipugin/telegram-bot-ruby) wrapper for Telegram API.

##Installation

Execute:
```shell
$ bundle
```

##Configuration

Add the name 'BOT_NAME' and token 'TOKEN' of your bot. Obtain them from [BotFather](https://core.telegram.org/bots#botfather)


Execute:
```shell
$ ruby bot.rb
```

##Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

##Usage

`/help`: shows the commands available

`/list`: gives stocks available in this bot

`/rate <currency code><currency code>`: get currency rate and chart using 3-digit currency code. (example: `/rate usdeur`)

`/stock <ticker>`: states the last traded price of *one* stock counter. (example: `/stock GOOG`)

`/charts <tag>`: (expert mode) depicts the graphical %change of some of the matching SG stocks and STI. (example: `/charts bank`)

`/stat <ticker>`: (expert mode) provides details about the stock counter (example: `/stat GOOG`)

##TODO
1. Write test for new commands
2. to update configuration
