module SmsComponent
  module Messages
    module Commands
      class SmsForward
        include Messaging::Message

        attribute :message_sid, String
        attribute :time, String
      end
    end
  end
end
