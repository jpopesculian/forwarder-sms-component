module SmsComponent
  module Handlers
    class Replies
      include Log::Dependency
      include Messaging::Handle
      include Messaging::StreamName

      include TwilioLib::Client::Messages::Replies
      include Messages::Events

      dependency :write, Messaging::Postgres::Write
      dependency :clock, Clock::UTC
      dependency :uuid, Identifier::UUID::Random
      dependency :store, Store
      dependency :processed, Utils::Processed

      def configure
        Messaging::Postgres::Write.configure(self)
        Clock::UTC.configure(self)
        Identifier::UUID::Random.configure(self)
        Store.configure(self)
        Utils::Processed.configure(self)
      end

      category :sms

      handle RecordSmsFetched do |record_sms_fetched|
        source_message_stream_name = record_sms_fetched.metadata.source_message_stream_name
        sms_id = Messaging::StreamName.get_id(source_message_stream_name)
        sms, version = store.fetch(sms_id, include: :version)

        current, ignored = processed.(record_sms_fetched, id: sms_id)
        return ignored.() if current

        sms_fetched = SmsFetched.follow(record_sms_fetched, copy: [
          :message_sid,
          :time,
          :from,
          :to,
          :body,
          :direction,
          :status
        ])
        sms_fetched.sms_id = sms_id
        sms_fetched.meta_position = record_sms_fetched.metadata.global_position
        stream_name = stream_name(sms_id)
        Try.(MessageStore::ExpectedVersion::Error) do
          write.(sms_fetched, stream_name, expected_version: version)
        end
      end

      handle RecordSmsSent do |record_sms_sent|
        source_message_stream_name = record_sms_sent.metadata.source_message_stream_name
        sms_id = Messaging::StreamName.get_id(source_message_stream_name)
        sms, version = store.fetch(sms_id, include: :version)

        current, ignored = processed.(record_sms_sent, id: sms_id)
        return ignored.() if current

        sms_sent = SmsDelivered.follow(record_sms_sent, copy: [
          :message_sid,
          :time,
          :from,
          :to,
          :body,
          :status_callback
        ])
        sms_sent.sms_id = sms_id
        sms_sent.meta_position = record_sms_sent.metadata.global_position
        stream_name = stream_name(sms_id)
        Try.(MessageStore::ExpectedVersion::Error) do
          write.(sms_sent, stream_name, expected_version: version)
        end
      end

    end
  end
end
