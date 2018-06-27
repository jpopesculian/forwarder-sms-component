module SmsComponent
  module Messages
    module Events
      class SmsForwardInitiated
        include Messaging::Message

        attribute :sms_id, String
        attribute :message_sid, String
        attribute :time, String
        attribute :processed_time, String
      end
    end
  end
end
