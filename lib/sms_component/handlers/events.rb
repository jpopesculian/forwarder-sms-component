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
      dependency :processed, Utils::Processed
      dependency :updated, Utils::Updated

      def configure
        Messaging::Postgres::Write.configure(self)
        TwilioLib::Client::SmsFetch.configure(self)
        TwilioLib::Client::SmsSend.configure(self)
        Store.configure(self)
        Utils::Processed.configure(self)
        Utils::Updated.configure(self)
      end

      category :sms

      handle SmsForwardInitiated do |initiated|
        sms_id = initiated.sms_id
        message_sid = initiated.message_sid

        current, ignored = processed.(initiated)
        return ignored.() if current

        reply_stream_name = command_stream_name(sms_id)

        sms_fetch.(
          message_sid: message_sid,
          reply_stream_name: reply_stream_name,
          previous_message: initiated
        )
      end

      handle SmsDeliverInitiated do |initiated|
        sms_id = initiated.sms_id
        reply_stream_name = command_stream_name(sms_id)

        current, ignored = processed.(initiated)
        return ignored.() if current

        sms_send.(
          to: initiated.to,
          from: initiated.from,
          body: initiated.body,
          status_callback: initiated.status_callback,
          reply_stream_name: reply_stream_name,
          previous_message: initiated
        )
      end

      handle SmsFetched do |sms_fetched|
        current, ignored = processed.(sms_fetched)
        return ignored.() if current

        return unless sms_fetched.metadata.reply?
        record_sms_received = RecordSmsReceived.follow(sms_fetched, exclude: [:meta_position])
        write.reply(record_sms_received)

        updated.(sms_fetched)
      end

      handle SmsDelivered do |sms_delivered|
        current, ignored = processed.(sms_delivered)
        return ignored.() if current

        return unless sms_delivered.metadata.reply?
        record_sms_sent = RecordSmsSent.follow(sms_delivered, exclude: [:meta_position])
        write.reply(record_sms_sent)

        updated.(sms_delivered)
      end
    end
  end
end
