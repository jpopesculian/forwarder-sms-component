module SmsComponent
  module Messages
    module Events
      class SmsFetched
        include Messaging::Message

        attribute :sms_id, String
        attribute :message_sid, String
        attribute :time, String
        attribute :from, String
        attribute :to, String
        attribute :body, String
        attribute :direction, String
        attribute :status, String
        attribute :meta_position, Integer
      end
    end
  end
end
