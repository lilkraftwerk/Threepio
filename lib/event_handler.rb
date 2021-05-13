# frozen_string_literal: true

ADD_EVENT_CONFIRM = 'Confirm: Add Event To Calendar'
CANCEL_EVENT_CONFIRM = 'Cancel: Do Not Add Event'

# Add events to a calendar
class EventHandler
  @@current_event = nil

  def self.check_message(message)
    message.include?('event')
  end

  def self.handle_message(message)
    begin
      case message
      when ADD_EVENT_CONFIRM.downcase
        confirm_event
      when CANCEL_EVENT_CONFIRM.downcase
        cancel_event
      else
        suggest_event(message)
      end
    rescue => e
      TelegramHelper.send_message("Adding event failed: #{e}")
      clear_current_event
    end
  end

  def self.helper_message
    'Add an event to your personal calendar'
  end

  def self.clear_current_event
    puts 'clearing event'
    @@current_event = nil
  end

  def self.confirm_event
    puts 'confirming event'
    puts @@current_event
    # add event to calendar here
    confirmation = "Event added to calendar: #{event_full_display_string}"
    TelegramHelper.remove_keyboard(confirmation)
    clear_current_event
  end

  def self.suggest_event(message)
    formatted_event = format_event_input(message)
    @@current_event = formatted_event
    question = "Confirm event: #{EventHandler.event_full_display_string}"
    answers =
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: [ADD_EVENT_CONFIRM, CANCEL_EVENT_CONFIRM],
        one_time_keyboard: true
      )
    TelegramHelper.send_keyboard(question, answers)
  end

  def self.current_event
    @@current_event
  end

  def self.cancel_event
    puts 'cancelling event'
    puts @@current_event
    TelegramHelper.remove_keyboard('Event not added.')
    clear_current_event
  end

  def self.event_full_display_string
    return 'No event found' if @@current_event.nil?

    "#{@@current_event[:event_name]} - #{@@current_event[:display_time]}"
  end

  def self.format_event_input(event_input)
    formatted_input = split_input_string(event_input)
    parsed_time = Chronic.parse(formatted_input[:time])
    display_time = parsed_time.strftime('%A, %d %B %Y, %H:%M')
    {
      event_name: formatted_input[:name],
      parsed_time: parsed_time,
      display_time: display_time
    }
  end

  def self.event_input_valid?(input_arr)
    # "party at 10pm december 31".split
    # should return ["party", "at", "10pm december 31"]
    # otherwise, not valid
    input_arr.length == 3
  end

  def self.split_input_string(input_string)
    without_event = input_string.sub('event', '').strip
    at_on_regex = /\s(at|on)\s/
    split_arr = without_event.split(at_on_regex)
    raise "Incorrect Event Input: #{input_string}" unless event_input_valid?(split_arr)
    {name: split_arr[0], time: split_arr[2]}
  end
end
