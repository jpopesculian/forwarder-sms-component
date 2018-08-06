module SmsComponent
  module Messages
    module Events
      class SmsUpdated
        include Messaging::Message

        attribute :sms_id, String
        attribute :processed_time, String
        attribute :meta_position, Integer
      end
    end
  end
end
