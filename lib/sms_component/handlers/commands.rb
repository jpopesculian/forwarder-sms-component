module SmsComponent
  module Handlers
    class Commands
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
        Messaging::Postgres::Write.configure(self)
        Clock::UTC.configure(self)
        Store.configure(self)
        Identifier::UUID::Random.configure(self)
      end

      category :sms

      handle SmsForward do |forward|
        sms_id = forward.sms_id
        # check if sms_forward has been initiated through store

        initiated = SmsForwardInitiated.follow(forward)
        initiated.processed_time = clock.iso8601

        stream_name = stream_name(initiated.sms_id)

        initiated.metadata.correlation_stream_name = stream_name
        write.initial(initiated, stream_name)
      end
    end
  end
end
