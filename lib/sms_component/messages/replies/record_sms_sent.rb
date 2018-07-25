module SmsComponent
  module Messages
    module Replies
      class RecordSmsSent
        include Messaging::Message

        attribute :sms_id, String
        attribute :message_sid, String
        attribute :time, String
        attribute :from, String
        attribute :to, String
        attribute :body, String
      end
    end
  end
end
