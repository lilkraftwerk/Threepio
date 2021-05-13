# frozen_string_literal: true

# number of times to reboot script before quitting
MAX_RETRIES = 3
# number of seconds to sleep between retries
SLEEP_TIME = 2

# Simple class for running the bot
class Threepio
  def initialize
    @retries = 0
    @handlers = [NBAGamesHandler, WeatherHandler, EventHandler]
    @should_continue = true
  end

  def stop_listening
    @should_continue = false
    raise UserAbortedError
  end

  def send_help_message
    help_message = @handlers.map do |handler|
      "➡️ <b>#{handler::MESSAGE_COMMAND}</b> - #{handler.helper_message}"
    end
    TelegramHelper.send_message(help_message.join("\n"))
    true
  end

  def listen_for_incoming_messages
    Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
      puts 'Starting bot...'
      bot.listen do |message|
        puts "Message received: #{message}"
        lowercase_text = message.text.downcase
        handle_incoming_message(lowercase_text)
      end
    end
  end

  def handle_incoming_message(message_text)
    stop_listening if %w[abort stop].include?(message_text)

    if message_text == 'help'
      send_help_message
      return
    end

    handler = find_appropriate_handler(message_text)
    if handler.nil?
      TelegramHelper.send_message('Your command was not understood. :(')
      return
    end

    handler.handle_message(message_text)
  end

  def find_appropriate_handler(message_text)
    @handlers.find { |handler| handler.check_message(message_text) }
  end

  def listen
    puts 'Hey, listen!'
    listen_for_incoming_messages
    rescue UserAbortedError => e
      TelegramHelper.send_message(e)
      puts e
      exit
    rescue StandardError => e
      error_msg = "Bot error: #{e}"
      puts error_msg
      TelegramHelper.send_message(error_msg)

      if @should_continue && @retries < MAX_RETRIES
        @retries += 1
        puts "Retrying in #{SLEEP_TIME} seconds... #{@retries} / #{MAX_RETRIES} times."
        sleep SLEEP_TIME
        retry
      else
        TelegramHelper.send_message('Reached retry limit or aborted, shutting down bot.')
      end
  end
end
