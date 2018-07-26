module SmsComponent
  class Sms
    include Schema::DataStructure

    attribute :id, String
    attribute :twilio_id, String
    attribute :received_time, Time
    attribute :sent_time, Time
    attribute :from, String
    attribute :to, String
    attribute :body, String
    attribute :valid, Boolean
    attribute :status_callback, String

    def inbound?
      !received_time.nil?
    end

    def outbound?
      !sent_time.nil?
    end
  end
end
