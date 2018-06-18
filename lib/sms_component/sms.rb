module SmsComponent
  class Sms
    include Schema::DataStructure

    attribute :message_sid, String
    attribute :received_time, Time
    attribute :sent_time, Time
    attribute :from, String
    attribute :to, String
    attribute :body, String
    attribute :valid, Boolean

    def inbound?
      !received_time.nil?
    end

    def outbound?
      !sent_time.nil?
    end
  end
end
