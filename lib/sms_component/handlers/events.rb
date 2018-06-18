module SmsComponent
  module Handlers
    class Commands
      include Log::Dependency
      include Messaging::Handle
      include Messaging::StreamName
      include Messages::Commands
      include Messages::Events

      dependency :fetch, TwilioLibComponent::Client::SmsFetch

      def configure
        TwilioLibComponent::Client::SmsFetch.configure(self)
      end

      handle SmsForwardInitiated do |initiated|
        message_sid = initiated.message_sid
        reply_stream_name = command_stream_name(message_sid)

        fetch.(
          message_sid: message_sid,
          reply_stream_name: reply_stream_name,
          previous_message: initiated
        )
      end

      handle SmsFetched do |fetched|
        binding.pry
      end
    end
  end
end
