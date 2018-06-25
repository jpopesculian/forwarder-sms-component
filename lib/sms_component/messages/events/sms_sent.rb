module SmsComponent
  module Messages
    module Events
      class SmsSent
        include Messaging::Message

        attribute :message_sid, String
        attribute :time, String
        attribute :from, String
        attribute :to, String
        attribute :body, String
      end
    end
  end
end
