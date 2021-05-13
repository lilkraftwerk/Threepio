# frozen_string_literal: true

require 'http'
require 'telegram/bot'
require 'open-uri'
require 'json'
require 'byebug'
require 'date'
require 'rufus-scheduler'
require 'trello'
require 'chronic'
require 'cgi'

require_relative './keys'

Dir['./lib/*.rb'].sort.each { |file| require file }

require_relative './threepio'

Trello.configure do |config|
  config.developer_public_key = TRELLO_KEY
  config.member_token = TRELLO_TOKEN
end
