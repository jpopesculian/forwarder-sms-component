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
    attribute :status, String

    def inbound?
      !received_time.nil?
    end

    def outbound?
      !sent_time.nil?
    end

    def set_time(time, direction = "inbound")
      parsed_time = Time.parse(time)
      case direction
      when "inbound"
        self.received_time = parsed_time
      else
        self.sent_time = parsed_time
      end
      parsed_time
    end
  end
end
