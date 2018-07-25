module SmsComponent
  module Messages
    module Events
      class SmsDeliverInitiated
        include Messaging::Message

        attribute :sms_id, String
        attribute :time, String
        attribute :to, String
        attribute :from, String
        attribute :body, String
        attribute :processed_time, String
      end
    end
  end
end
