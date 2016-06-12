require 'telegram/bot'
require 'telegram/bot/botan'
require_relative 'config'

module Drumpf_bot

    class DrumpfBot

        def self.start()
        end

        def initialize()
            @bot = Telegram::Bot::Client.new(BotConfig::Telegram_token)

            if BotConfig.has_botan_token
                @bot.enable_botan!(BotConfig::Botan_token)
            end
        end

        def listen(&block)
            @bot.listen &block
        end

        def process_update(message)
            case message

                when Telegram::Bot::Types::Message

                    if message.left_chat_member or message.new_chat_member or message.new_chat_title or message.delete_chat_photo or message.group_chat_created or message.supergroup_chat_created or message.channel_chat_created or message.migrate_to_chat_id or message.migrate_from_chat_id or message.pinned_message
                      return
                    end

                    if message.text == "/start"
                        @bot.api.send_message(chat_id: message.chat.id, text: "Add me to a group and I will randomly reply to some of your messages with my fauvorite quotes.")
                        if BotConfig.has_botan_token
                          @bot.track('message', message.from.id, message_type: 'start')
                        end
                    else
                        closest = getClosestSentence(message.text)
                        if closest
                          @bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: closest)
                          if BotConfig.has_botan_token
                            @bot.track('message', message.from.id, message_type: 'normal')
                          end
                        end
                    end

            end
        end

        def set_webhook(url)
            @bot.api.set_webhook(url: url)
        end

        private

        def getClosestSentence(sentence)

          if not sentence
            return nil
          end

          uri = URI('http://trumpspeak')
          req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' =>'application/json'})
          req.body = {sentence: sentence}.to_json
          res = Net::HTTP.start(uri.hostname, uri.port) do |http|
            http.request(req)
          end
          return res.body

        end
    end

end
