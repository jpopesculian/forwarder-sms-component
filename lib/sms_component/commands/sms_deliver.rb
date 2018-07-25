module SmsComponent
  module Commands
    class SmsDeliver
      include Command

      default_attr_name :sms_deliver

      def self.call(to:, from:, body:, sms_id: nil, time: nil, reply_stream_name: nil, previous_message: nil)
        instance = self.build
        instance.(
          sms_id: sms_id,
          to: to,
          from: from,
          body: body,
          time: time,
          reply_stream_name: reply_stream_name,
          previous_message: previous_message
        )
      end

      def call(to:, from:, body:, sms_id: nil, time: nil, reply_stream_name: nil, previous_message: nil)
        sms_id ||= Identifier::UUID::Random.get
        time ||= Clock::UTC.iso8601

        sms_deliver = self.class.build_message(Messages::Commands::SmsDeliver, previous_message)

        sms_deliver.sms_id = sms_id
        sms_deliver.to = to
        sms_deliver.from = from
        sms_deliver.body = body
        sms_deliver.time = time

        stream_name = command_stream_name(sms_id)

        write.(sms_deliver, stream_name, reply_stream_name: reply_stream_name)

        sms_deliver
      end
    end
  end
end
