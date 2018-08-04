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
        sms_id = initiated.sms_id
        message_sid = initiated.message_sid

        position = initiated.metadata.global_position

        sms = store.fetch(sms_id)
        if sms.current?(position)
          logger.info(tag: :ignored) { "Event ignored (Event: #{initiated.message_type}, Request ID: #{sms_id}" }
          return
        end

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

        position = initiated.metadata.global_position

        sms = store.fetch(sms_id)
        if sms.current?(position)
          logger.info(tag: :ignored) { "Event ignored (Event: #{initiated.message_type}, Request ID: #{sms_id}" }
          return
        end

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
        sms_id = sms_fetched.sms_id
        sms, version = store.fetch(sms_id, include: :version)
        reply_stream_name = command_stream_name(sms_id)

        return unless sms_fetched.metadata.reply?
        record_sms_received = RecordSmsReceived.follow(sms_fetched, exclude: [:meta_position])
        write.reply(record_sms_received)
      end

      handle SmsDelivered do |sms_delivered|
        return unless sms_delivered.metadata.reply?
        record_sms_sent = RecordSmsSent.follow(sms_delivered, exclude: [:meta_position])
        write.reply(record_sms_sent)
      end
    end
  end
end
