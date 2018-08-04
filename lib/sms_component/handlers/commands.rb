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
        sms, version = store.fetch(sms_id, include: :version)

        position = forward.metadata.global_position
        if sms.current?(position)
          logger.info(tag: :ignored) { "Event ignored (Event: #{forward.message_type}, Request ID: #{sms_id}" }
          return
        end

        initiated = SmsForwardInitiated.follow(forward)
        initiated.processed_time = clock.iso8601
        initiated.meta_position = position

        stream_name = stream_name(initiated.sms_id)

        initiated.metadata.correlation_stream_name = stream_name
        Try.(MessageStore::ExpectedVersion::Error) do
          write.(initiated, stream_name, expected_version: version)
        end
      end

      handle SmsDeliver do |deliver|
        sms_id = deliver.sms_id
        sms, version = store.fetch(sms_id, include: :version)

        position = deliver.metadata.global_position
        if sms.current?(position)
          logger.info(tag: :ignored) { "Event ignored (Event: #{deliver.message_type}, Request ID: #{sms_id}" }
          return
        end

        initiated = SmsDeliverInitiated.follow(deliver)
        initiated.processed_time = clock.iso8601
        initiated.meta_position = position

        stream_name = stream_name(initiated.sms_id)

        initiated.metadata.correlation_stream_name = stream_name
        Try.(MessageStore::ExpectedVersion::Error) do
          write.(initiated, stream_name, expected_version: version)
        end
      end
    end
  end
end
