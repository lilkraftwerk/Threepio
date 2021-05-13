# frozen_string_literal: true

# Send the weather for the next 24 hours
class WeatherHandler
  MESSAGE_COMMAND = 'WEATHER'

  def self.check_message(message)
    message.include?('weather')
  end

  def self.handle_message(_)
    send_weather_message
  end

  def self.helper_message
    'Berlin weather for the next 24 hours'
  end

  def self.numbers_to_emojis(input_string)
    nums = %w[0️⃣ 1️⃣ 2️⃣ 3️⃣ 4️⃣ 5️⃣ 6️⃣ 7️⃣ 8️⃣ 9️⃣]
    input_string.chars.map { |char| nums[char.to_i] }
  end

  def self.icon_map(input)
    {
      '02' => '☁️',
      '03' => '☁️',
      '04' => '☁️',
      '09' => '🌧️',
      '10' => '🌧️',
      '11' => '🌩️',
      '13' => '❄️',
      '50' => '🌫️'
    }[
      input
    ]
  end

  def self.get_icon(icon_code)
    sun = '🌞'
    moon = '🌚'

    return sun if icon_code == '01d'
    return moon if icon_code == '01n'

    prefix = moon if icon_code.include?('n')
    prefix = sun if icon_code.include?('d')
    icon_number = icon_code[0..1]
    icon = icon_map(icon_number)
    "#{prefix}#{icon}"
  end

  def self.parse_current(parsed_response)
    current_info = parsed_response['current']
    time = Time.at(current_info['dt'].to_i)
    time_format = time.strftime('%A, %d %B, %Y')
    sunrise = Time.at(current_info['sunrise'].to_i).strftime('%k:%M')
    sunset = Time.at(current_info['sunset'].to_i).strftime('%k:%M')
    ["Weather for #{time_format}", "☀️⬆️: #{sunrise} - ☀️⬇️: #{sunset}"]
  end

  def self.fetch_weather
    berlin_lon = 13.4105
    berlin_lat = 52.5244
    exclude = 'minutely,alerts,daily'
    weather_url =
      "https://api.openweathermap.org/data/2.5/onecall?lat=#{berlin_lat}&lon=#{berlin_lon}&exclude=#{exclude}&units=metric&appid=#{WEATHER_KEY}"
    response = HTTP.get(weather_url)
    JSON.parse(response)
  end

  def self.parse_hourly(hourly_info)
    time = Time.at(hourly_info['dt'].to_i).hour.to_s
    time = "0#{time}" if time.length == 1
    time = numbers_to_emojis(time)
    temp = hourly_info['temp'].round.to_s
    type = hourly_info['weather'].first
    description = type['main']
    icon = type['icon']
    "#{time} 🌡️ #{temp}©️ - #{description} - #{get_icon(icon)}"
  end

  def self.format_hourly(parsed_response)
    hourly = parsed_response['hourly']
    hourly[0..24].map { |current| parse_hourly(current) }
  end

  def self.send_weather_message
    parsed_response = fetch_weather
    final_message = []
    final_message << parse_current(parsed_response)
    final_message << format_hourly(parsed_response)
    Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
      bot.api.send_message(
        chat_id: CHAT_ID,
        text: final_message.flatten.join("\n")
      )
    end
  end
end
