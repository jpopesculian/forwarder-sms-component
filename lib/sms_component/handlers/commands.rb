module SmsComponent
  module Handlers
    class Events
      include Log::Dependency
      include Messaging::Handle
      include Messaging::StreamName
      include Messages::Commands
      include Messages::Events

      dependency :write, Messaging::Postgres::Write
      dependency :clock, Clock::UTC
      dependency :store, Store
      dependency :identifier, Identifier::UUID::Random

      def configure
        TwilioLibComponent::Client::SmsFetch.configure(self)
      end

      handle SmsForward do |forward|
        message_sid = forward.message_sid
        # check if sms_forward has been initiated through store

        initiated = SmsForwardInitiated.follow(forward)
        initiated.processed_time = clock.iso8601

        stream_name = stream_name(initiated.message_sid)

        initiated.metadata.correlation_stream_name = stream_name
        write.initial(initiated, stream_name)
      end
    end
  end
end
