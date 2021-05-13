# frozen_string_literal: true

# Schedule certain tasks at specific times
class TelegramScheduler
  def launch
    puts 'Starting scheduler...'

    scheduler = Rufus::Scheduler.new

    # daily at 7am
    scheduler.cron '00 07 * * *' do
      TelegramWeather.send_weather_message
    end

    # daily at 7am
    scheduler.cron '00 07 * * *' do
      NBAGames.send_games_message
    end

    # test at 8pm
    scheduler.cron '00 20 * * *' do
      TelegramWeather.send_weather_message
    end

    # test at 8pm
    scheduler.cron '00 20 * * *' do
      NBAGames.send_games_message
    end

    # test at 10 mins past hour
    scheduler.cron '10 * * * *' do
      TelegramWeather.send_weather_message
    end

    # test at 10 mins past hour
    scheduler.cron '10 * * * *' do
      NBAGames.send_games_message
    end

    # fridays at 6pm
    scheduler.cron '00 18 * * 5' do
      TrelloBot.make_release
    end
  end
end
