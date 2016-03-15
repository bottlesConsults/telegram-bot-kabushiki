require_relative 'constants'

module FormatHelper
  def format(data)
    return unless respond_to?("format_#{data[:type]}")
    send("format_#{data[:type]}", data[:data])
  end

  def format_list(data)
    result = ''
    data.each_pair do |key, value|
      result << "#{key}    "
      result << "<b>#{value[:name]}</b>    "
      result << "#{value[:tag]}\n"
    end
    result
  end

  def format_currency(data)
    result = ''
    data.each_value do |value|
      result << "<i>#{value[:from_code]} 1 = "
      result << "#{value[:to_code]} #{value[:amount]} "
      result << "#{Emoji.trend(value[:change_amount].to_f)}</i>\n\n"
    end
    result
  end

  def format_price(data)
    result = ''
    data.each_pair do |key, value|
      result << "#{key} "
      result << "<b>$#{value[:amount]}</b> "
      result << "#{Emoji.trend(value[:change_amount].to_f)} "
      result << "#{value[:change_amount]}, "
      result << "#{value[:change_percent]}, "
      result << "#{value[:name]}\n"
    end
    result
  end

  def format_stat(data)
    result = ''
    data.each_pair do |key, value|
      result << "#{value[:name]} #{key.upcase}\n"
      result << print_spec(value)
      result << print_news(value[:news])
    end
    result
  end

  # TODO: refactor this, inconsistent with other method
  def print_spec(data)
    result = ''
    result << "#{Emoji.trend(data[:change_amount].to_f)}"
    result << "  <b>$#{data[:amount]}</b>  #{data[:change_amount]}  #{data[:change_percent]}\n"
    result << "[dividend]   <b>$#{data[:dividend]}</b>\n"
    result << "[pe ratio]   <b>$#{data[:pe]}</b>\n"
    result << "[volume]     <b>#{data[:volume]}</b>\n\n"
    result
  end

  # TODO: refactor this, inconsistent with other method
  def print_news(data)
    result = ''
    unless data.nil?
      data.each do |hash|
        result << "<a href='#{hash[:url]}'>#{hash[:title]}</a>\n"
        result << "#{hash[:date]}\n\n"
      end
    end
    result
  end
end
