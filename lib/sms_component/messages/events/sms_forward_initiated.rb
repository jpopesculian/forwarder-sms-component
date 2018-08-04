module SmsComponent
  module Messages
    module Events
      class SmsForwardInitiated
        include Messaging::Message

        attribute :sms_id, String
        attribute :message_sid, String
        attribute :time, String
        attribute :processed_time, String
        attribute :meta_position, Integer
      end
    end
  end
end
