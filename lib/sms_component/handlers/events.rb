module SmsComponent
  module Handlers
    class Events
      include Log::Dependency
      include Messaging::Handle
      include Messaging::StreamName
      include Messages::Commands
      include Messages::Events

      dependency :sms_fetch, TwilioLib::Client::SmsFetch
      dependency :sms_send, TwilioLib::Client::SmsSend
      dependency :store, Store

      def configure
        TwilioLib::Client::SmsFetch.configure(self)
        TwilioLib::Client::SmsSend.configure(self)
        Store.configure(self)
      end

      category :sms

      handle SmsForwardInitiated do |initiated|
        message_sid = initiated.message_sid
        reply_stream_name = command_stream_name(message_sid)

        sms_fetch.(
          message_sid: message_sid,
          reply_stream_name: reply_stream_name,
          previous_message: initiated
        )
      end

      handle SmsFetched do |sms_fetched|
        message_sid = sms_fetched.message_sid
        sms, version = store.fetch(message_sid, include: :version)
        # TODO need a doain specific id
        reply_stream_name = command_stream_name(message_sid)

        sms_send.(
          to: '+19165854267',
          from: '+14158542955',
          body: sms.body,
          reply_stream_name: reply_stream_name,
          previous_message: sms_fetched
        )
      end
    end
  end
end
