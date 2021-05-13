# frozen_string_literal: true

# Raised when I send "abort" or "stop" to the Telegram bot
class UserAbortedError < StandardError
  def initialize(message = 'Abort message received. Closing bot.')
    super
  end
end
