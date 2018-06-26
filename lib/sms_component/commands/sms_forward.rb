module SmsComponent
  module Commands
    class SmsForward
      include Command

      def self.configure(receiver, attr_name: nil)
        attr_name ||= :sms_forward
        instance = build
        receiver.public_send("#{attr_name}=", instance)
      end

      def self.call(message_sid:, time: nil, reply_stream_name: nil, previous_message: nil)
        instance = self.build
        time ||= Clock::UTC.iso8601
        instance.(
          message_sid: message_sid,
          time: time,
          reply_stream_name: reply_stream_name,
          previous_message: previous_message
        )
      end

      def call(message_sid:, time:, reply_stream_name: nil, previous_message: nil)
        sms_forward = self.class.build_message(Messages::Commands::SmsForward, previous_message)

        sms_forward.message_sid = message_sid
        sms_forward.time = time

        stream_name = command_stream_name(message_sid)

        write.(sms_forward, stream_name, reply_stream_name: reply_stream_name)

        sms_forward
      end
    end
  end
end
