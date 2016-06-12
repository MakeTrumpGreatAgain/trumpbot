require 'telegram/bot'
require_relative 'drumpf_bot'
require_relative 'config'

BotConfig::require_tokens()

error_count = 0

Drumpf_bot::DrumpfBot.start()

begin
    
	bot = Drumpf_bot::DrumpfBot.new()
    bot.set_webhook('')

	bot.listen do |message|
		bot.process_update message
		error_count = 0
	end




rescue => e
    error_count += 1
    puts e.to_s
    open('hideit_server_log.txt', 'a') do |f|
        f.puts e.to_s
    end
    if error_count < 5
        sleep(1)
        retry
    end
end
