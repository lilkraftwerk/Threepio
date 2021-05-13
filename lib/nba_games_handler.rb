# frozen_string_literal: true

# Fetch NBA games from yesterday and today (USA time) to get yesterday's finished games
# and today's upcoming games
class NBAGamesHandler
  MESSAGE_COMMANDS = 'NBA'

  def self.check_message(message)
    message.include?('nba')
  end

  def self.handle_message(_)
    send_games_message
  end

  def self.helper_message
    'NBA schedule for today and tomorrow'
  end

  def self.send_games_message
    formatted_games =
      fetch_games.map { |current_game| parse_game_state(current_game) }
    results = process_all_games(formatted_games)
    Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
      bot.api.send_message(
        chat_id: CHAT_ID,
        parse_mode: 'HTML',
        text: results.flatten.join("\n")
      )
    end
  end

  def self.parse_game_state(game)
    {
      visitor_name: game['visitor_team']['name'],
      visitor_score: game['visitor_team_score'],
      home_name: game['home_team']['name'],
      home_score: game['home_team_score'],
      postseason: game['postseason'],
      status: game['status']
    }
  end

  def self.parse_final_game(game)
    # no spoilers during the playoffs
    postseason_format =
      "🏠#{game[:home_name]} - ??? vs. ✈️#{game[:visitor_name]} - ???"
    return postseason_format if game[:postseason] == true

    home_team_result = "🏠 #{game[:home_name]} - #{game[:home_score]}"
    away_team_result = "✈️ #{game[:visitor_name]} - #{game[:visitor_score]}"

    home_team_won = game[:home_score] > game[:visitor_score]

    # home team wins
    return "<u><b>#{home_team_result}</b></u> vs. #{away_team_result}" if home_team_won

    # visiting team wins
    "#{home_team_result} vs. <u><b>#{away_team_result}</b></u>"
  end

  def self.parse_upcoming_game(game)
    game_time = game[:status]
    berlin_time = Time.parse(game_time) + (60 * 60 * 6)
    in_berlin = berlin_time.strftime('%R %p')

    "✈️ #{game[:visitor_name]} at 🏠 #{game[:home_name]} - #{game_time} / #{in_berlin} in Berlin"
  end

  def self.fetch_games
    yesterday = Date.today - 1
    today = Date.today
    today_parsed = today.strftime('%Y-%m-%d')
    yesterday_parsed = yesterday.strftime('%Y-%m-%d')
    game_url =
      "https://www.balldontlie.io/api/v1/games?start_date=#{yesterday_parsed}&end_date=#{today_parsed}"
    JSON.parse(HTTP.get(game_url))['data']
  end

  def self.partition_games(games)
    final, upcoming = games.partition { |game| game[:status] == 'Final' }
    upcoming_by_time = upcoming.sort_by { |game| Time.parse(game[:status]) }
    [final, upcoming_by_time]
  end

  def self.process_all_games(all_games)
    final, upcoming = partition_games(all_games)
    [
      '🏀🏀🏀 NBA GAMES 🏀🏀🏀',
      '<i>FINISHED</i>',
      final.map { |final_game| parse_final_game(final_game) },
      '<i>UPCOMING</i>',
      upcoming.map { |upcoming_game| parse_upcoming_game(upcoming_game) }
    ]
  end
end
