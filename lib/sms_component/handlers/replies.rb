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

      def configure
        Messaging::Postgres::Write.configure(self)
        Clock::UTC.configure(self)
        Identifier::UUID::Random.configure(self)
        Store.configure(self)
      end

      category :sms

      handle RecordSmsFetched do |record_sms_fetched|
        source_message_stream_name = record_sms_fetched.metadata.source_message_stream_name
        sms_id = Messaging::StreamName.get_id(source_message_stream_name)
        sms_fetched = SmsFetched.follow(record_sms_fetched, include: [
          :message_sid,
          :time,
          :from,
          :to,
          :body,
          :direction,
          :status
        ])
        sms_fetched.sms_id = sms_id
        stream_name = stream_name(sms_id)
        write.(sms_fetched, stream_name)
      end

      handle RecordSmsSent do |record_sms_sent|
        source_message_stream_name = record_sms_sent.metadata.source_message_stream_name
        sms_id = Messaging::StreamName.get_id(source_message_stream_name)
        sms_sent = SmsDelivered.follow(record_sms_sent, include: [
          :message_sid,
          :time,
          :from,
          :to,
          :body,
          :status_callback
        ])
        sms_sent.sms_id = sms_id
        stream_name = stream_name(sms_id)
        write.(sms_sent, stream_name)
      end

    end
  end
end
