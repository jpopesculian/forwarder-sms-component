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

      category :sms_component

      handle RecordSmsFetched do |record_sms_fetched|
        source_message_stream_name = record_sms_fetched.metadata.source_message_stream_name
        message_sid = get_id(source_message_stream_name)

      end

    end
  end
end
