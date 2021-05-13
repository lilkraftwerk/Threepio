
class TrelloHelper
    def self.add_to_backlog(name)
        card = Trello::Card.create({
            name: name,
            list_id: TRELLO_LISTS[:Backlog]
        })
    end

    def self.add_to_this_week(name)
        card = Trello::Card.create({
            name: name,
            list_id: TRELLO_LISTS[:ThisWeek]
        })
    end

    def self.add_to_german_words(german_word)
        card = Trello::Card.create({
            name: german_word,
            list_id: TRELLO_LISTS[:GermanWords]
        })
    end

    def self.add_to_reminders(thing_to_remember)
        card = Trello::Card.create({
            name: thing_to_remember,
            list_id: TRELLO_LISTS[:Remember]
        })
    end

    def self.show_all_reminders
        remembers = Trello::List.find(TRELLO_LISTS[:Remember]).cards
        final = ["📋  Reminders 📋"]
        remembers.each do |current_remember|
            final << current_remember.name
        end

        Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
            bot.api.send_message(chat_id: CHAT_ID, parse_mode: 'MarkdownV2', text: final.join("\n"))
        end
    end

    def self.make_release
        finished_list = Trello::List.find(TRELLO_LISTS[:Done])
        unfinished_list = Trello::List.find(TRELLO_LISTS[:ThisWeek])

        cards_done_this_week = finished_list.cards
        cards_unfinished_this_week = unfinished_list.cards
        
        finished_names = []
        cards_done_this_week.each do |card|
            finished_names << card.name
        end

        unfinished_names = []
        cards_unfinished_this_week.each do |card|
            unfinished_names << card.name
        end

        date = Time.now.strftime("%B %e, %Y")
        final_title = "#{date} - #{finished_names.join(" | ")}"
        release_card = Trello::Card.create({
            name: final_title,
            list_id: TRELLO_LISTS[:Releases]
        })

        info = []
        info << "Release For #{date}"
        info << "*FINISHED*"

        finished_names.each do |finished_name|
            info << "✅ #{finished_name}"
        end

        info << "*NOT FINISHED*"

        unfinished_names.each do |unfinished_name|
            info << "❌ #{unfinished_name}"
        end

        puts info.join("\n")
        Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
            bot.api.send_message(chat_id: CHAT_ID, parse_mode: 'MarkdownV2', text: info.join("\n"))
        end

        finished_list.archive_all_cards
    end

    def self.weekly_progress
        finished_list = Trello::List.find(TRELLO_LISTS[:Done])
        unfinished_list = Trello::List.find(TRELLO_LISTS[:ThisWeek])

        cards_done_this_week = finished_list.cards
        cards_unfinished_this_week = unfinished_list.cards
        
        finished_names = []
        cards_done_this_week.each do |card|
            finished_names << card.name
        end

        unfinished_names = []
        cards_unfinished_this_week.each do |card|
            unfinished_names << card.name
        end

        date = Time.now.strftime("%B %e, %Y")
       
        info = []
        info << "Progress For #{date}"
        info << "*FINISHED*"

        finished_names.each do |finished_name|
            info << "✅ #{finished_name}"
        end

        info << "*NOT FINISHED*"

        unfinished_names.each do |unfinished_name|
            info << "❌ #{unfinished_name}"
        end

        puts info.join("\n")
        Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
            bot.api.send_message(chat_id: CHAT_ID, parse_mode: 'MarkdownV2', text: info.join("\n"))
        end
    end
end