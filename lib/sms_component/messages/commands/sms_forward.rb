module SmsComponent
  module Messages
    module Commands
      class SmsForward
        include Messaging::Message

        attribute :sms_id, String
        attribute :message_sid, String
        attribute :time, String
      end
    end
  end
end
