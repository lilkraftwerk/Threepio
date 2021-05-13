# frozen_string_literal: true

# Simple class for sending
class TelegramHelper
  def self.send_message(message_content)
    Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
      bot.api.send_message(
        chat_id: CHAT_ID,
        parse_mode: 'HTML',
        text: message_content
      )
    end
  end

  def self.send_keyboard(message_content, keyboard)
    Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
      bot.api.send_message(
        chat_id: CHAT_ID,
        text: message_content,
        reply_markup: keyboard
      )
    end
  end

  def self.remove_keyboard(message)
    keyboard =
      Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
      bot.api.send_message(
        chat_id: CHAT_ID,
        text: message,
        reply_markup: keyboard
      )
    end
  end

  def self.clear_update_queue
    begin
      Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
        updates = bot.api.get_updates
        max_id = updates['result'].map { |message| message['update_id'] }.max
        raise 'No max ID in updates queue.' if max_id.nil?
        puts 'Clearing queue...'
        bot.api.get_updates(offset: max_id + 1)
        puts 'Queue clear.'
      end
    rescue => e
      puts "Failed to fetch/clear updates: #{e}"
    end
  end
end
