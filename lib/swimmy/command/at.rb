require 'date'

module Swimmy
  module Command
    class At < Swimmy::Command::Base
      COMMAND_SCHEDULE = []

      command "at" do |client, data, match|
        arg = match[:expression].split(' ', 3)
        if arg.size == 3 then

          now = DateTime.now
          date = DateTime.parse(DateTime.parse(arg[0]).strftime("%Y%m%dT%H:%M:%S") + DateTime.now.zone) rescue false

          if ! date then
            client.say(channel: data.channel, text: "時刻の指定がおかしいです")
            break
          elsif date <= now then
            client.say(channel: data.channel, text: "未来の時間を指定してください")
            break
          else
            COMMAND_SCHEDULE.append({date: date, text: arg[2], channel: data.channel, user: data.user})
            client.say(channel: data.channel, text: "<##{data.channel}> で #{date} 頃， #{arg[2]} を実行します．")
          end

        else
          client.say(channel: data.channel, text: help_message("at"))
        end
      end

      help do
        title "at"
        desc "指定した日時にコマンドを実行します．"
        long_desc "at <日時> do <文字列> - <日時> 頃，<文字列> をコマンドとして実行します．\n"
      end

      tick do |client, data|
        puts "at command..."
        now = DateTime.now

        COMMAND_SCHEDULE.each do |elem|
          if elem[:date] <= now
            puts "at command sending message..."
            client.say(channel: elem[:channel], text: "at コマンドによるコマンド実行です．")
            text = 'swimmy ' + elem[:text]
            SlackRubyBot::Hooks::Message.new.call(
            client,
            Hashie::Mash.new(type: 'message', text: text, channel: elem[:channel], user: elem[:user])
            )
            true
          else
            false
          end
        end
      end

    end # class Do
  end # module Command
end # module Swimmy
