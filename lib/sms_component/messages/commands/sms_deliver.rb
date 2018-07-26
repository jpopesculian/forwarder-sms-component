module SmsComponent
  module Messages
    module Commands
      class SmsDeliver
        include Messaging::Message

        attribute :sms_id, String
        attribute :time, String
        attribute :to, String
        attribute :from, String
        attribute :body, String
        attribute :status_callback, String
      end
    end
  end
end
