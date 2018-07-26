module SmsComponent
  module Messages
    module Events
      class SmsDelivered
        include Messaging::Message

        attribute :sms_id, String
        attribute :message_sid, String
        attribute :time, String
        attribute :from, String
        attribute :to, String
        attribute :body, String
        attribute :status_callback, String
      end
    end
  end
end
