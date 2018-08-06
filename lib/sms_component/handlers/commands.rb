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
      dependency :processed, Utils::Processed

      def configure
        Messaging::Postgres::Write.configure(self)
        Clock::UTC.configure(self)
        Store.configure(self)
        Identifier::UUID::Random.configure(self)
        Utils::Processed.configure(self)
      end

      category :sms

      handle SmsForward do |forward|
        sms_id = forward.sms_id
        sms, version = store.fetch(sms_id, include: :version)

        current, ignored = processed.(forward)
        return ignored.() if current

        initiated = SmsForwardInitiated.follow(forward)
        initiated.processed_time = clock.iso8601
        initiated.meta_position = forward.metadata.global_position

        stream_name = stream_name(initiated.sms_id)

        initiated.metadata.correlation_stream_name = stream_name
        Try.(MessageStore::ExpectedVersion::Error) do
          write.(initiated, stream_name, expected_version: version)
        end
      end

      handle SmsDeliver do |deliver|
        sms_id = deliver.sms_id
        sms, version = store.fetch(sms_id, include: :version)

        current, ignored = processed.(deliver)
        return ignored.() if current

        initiated = SmsDeliverInitiated.follow(deliver)
        initiated.processed_time = clock.iso8601
        initiated.meta_position = deliver.metadata.global_position

        stream_name = stream_name(initiated.sms_id)

        initiated.metadata.correlation_stream_name = stream_name
        Try.(MessageStore::ExpectedVersion::Error) do
          write.(initiated, stream_name, expected_version: version)
        end
      end
    end
  end
end
