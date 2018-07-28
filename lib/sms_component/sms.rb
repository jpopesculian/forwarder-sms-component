module SmsComponent
  class Sms
    include Schema::DataStructure

    INBOUND_DIRECTION = "inbound"
    OUTBOUND_DIRECTION = "outbound"

    attribute :id, String
    attribute :twilio_id, String
    attribute :time, String
    attribute :from, String
    attribute :to, String
    attribute :body, String
    attribute :valid, Boolean
    attribute :status_callback, String
    attribute :status, String
    attribute :direction, String

    def time=(time)
      super(Time.parse(time))
    end

    def direction=(direction)
      super(direction == INBOUND_DIRECTION ? INBOUND_DIRECTION : OUTBOUND_DIRECTION)
    end

    def inbound?
      direction == INBOUND_DIRECTION
    end

    def outbound?
      direction == OUTBOUND_DIRECTION
    end

    def contact
      inbound? ? from : to
    end
  end
end
