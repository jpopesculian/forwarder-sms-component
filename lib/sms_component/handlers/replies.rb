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
      dependency :store, Store

      def configure
        Messaging::Postgres::Write.configure(self)
        Clock::UTC.configure(self)
        Store.configure(self)
      end

      category :sms

      handle RecordSmsFetched do |record_sms_fetched|
        source_message_stream_name = record_sms_fetched.metadata.source_message_stream_name
        message_sid = Messaging::StreamName.get_id(source_message_stream_name)
        sms_fetched = SmsFetched.follow(record_sms_fetched, include: [
          :message_sid,
          :time,
          :from,
          :to,
          :body
        ])
        stream_name = stream_name(message_sid)
        write.(sms_fetched, stream_name)
      end

      handle RecordSmsSent do |record_sms_sent|
        source_message_stream_name = record_sms_sent.metadata.source_message_stream_name
        message_sid = Messaging::StreamName.get_id(source_message_stream_name)
        sms_sent = SmsSent.follow(record_sms_sent, include: [
          :message_sid,
          :time,
          :from,
          :to,
          :body
        ])
        stream_name = stream_name(message_sid)
        write.(sms_sent, stream_name)
      end

    end
  end
end
