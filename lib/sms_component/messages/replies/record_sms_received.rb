module SmsComponent
  module Messages
    module Replies
      class RecordSmsReceived
        include Messaging::Message

        attribute :sms_id, String
        attribute :message_sid, String
        attribute :time, String
        attribute :from, String
        attribute :to, String
        attribute :body, String
        attribute :direction, String
        attribute :status, String
      end
    end
  end
end
