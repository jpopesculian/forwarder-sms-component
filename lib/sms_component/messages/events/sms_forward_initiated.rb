module SmsComponent
  module Messages
    module Events
      class SmsForwardInitiated
        include Messaging::Message

        attribute :message_sid, String
        attribute :time, String
        attribute :processed_time, String
      end
    end
  end
end
