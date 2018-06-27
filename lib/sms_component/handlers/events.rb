module SmsComponent
  module Handlers
    class Events
      include Log::Dependency
      include Messaging::Handle
      include Messaging::StreamName
      include Messages::Events
      include Messages::Replies

      dependency :write, Messaging::Postgres::Write
      dependency :sms_fetch, TwilioLib::Client::SmsFetch
      dependency :sms_send, TwilioLib::Client::SmsSend
      dependency :store, Store

      def configure
        Messaging::Postgres::Write.configure(self)
        TwilioLib::Client::SmsFetch.configure(self)
        TwilioLib::Client::SmsSend.configure(self)
        Store.configure(self)
      end

      category :sms

      handle SmsForwardInitiated do |initiated|
        message_sid = initiated.message_sid
        sms_id = initiated.sms_id
        reply_stream_name = command_stream_name(sms_id)

        sms_fetch.(
          message_sid: message_sid,
          reply_stream_name: reply_stream_name,
          previous_message: initiated
        )
      end

      handle SmsFetched do |sms_fetched|
        sms_id = sms_fetched.sms_id
        sms, version = store.fetch(sms_id, include: :version)
        reply_stream_name = command_stream_name(sms_id)

        sms_send.(
          to: '+19165854267',
          from: '+14158542955',
          body: sms.body,
          reply_stream_name: reply_stream_name,
          previous_message: sms_fetched
        )

        return unless sms_fetched.metadata.reply?
        record_sms_received = RecordSmsReceived.follow(sms_fetched)
        write.reply(record_sms_received)
      end
    end
  end
end
