module SmsComponent
  module Utils
    class Updated
      include Messaging::StreamName
      include Messages::Events

      category :sms

      dependency :write, Messaging::Postgres::Write
      dependency :clock, Clock::UTC

      def self.configure(receiver, attr_name: nil)
        attr_name ||= :updated
        instance = build
        receiver.public_send("#{attr_name}=", instance)
      end

      def self.build
        instance = new
        instance.configure
        instance
      end

      def configure
        Messaging::Postgres::Write.configure(self)
        Clock::UTC.configure(self)
      end

      def call(message)
        sms_id = message.sms_id
        stream_name = stream_name(sms_id)
        position = message.metadata.global_position
        time = clock.iso8601

        sms_updated = SmsUpdated.follow(message, copy: [:sms_id])
        sms_updated.meta_position = position
        sms_updated.processed_time = time

        write.(sms_updated, stream_name)
      end
    end
  end
end

