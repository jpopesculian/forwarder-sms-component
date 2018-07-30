module SmsComponent
  class Sms
    include Schema::DataStructure

    INBOUND_DIRECTION = "inbound"
    OUTBOUND_DIRECTION = "outbound"

    attribute :id, String
    attribute :twilio_id, String
    attribute :time, Time
    attribute :from, String
    attribute :to, String
    attribute :body, String
    attribute :valid, Boolean
    attribute :status_callback, String
    attribute :status, String
    attribute :direction, String

    def set_time(time)
      self.time = Time.parse(time)
    end

    def set_direction(direction)
      self.direction = (
        direction == INBOUND_DIRECTION ?
        INBOUND_DIRECTION :
        OUTBOUND_DIRECTION
      )
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
