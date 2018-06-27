module SmsComponent
  class Projection
    include EntityProjection
    include Messages::Events

    entity_name :sms

    apply SmsFetched do |fetched|
      sms.twilio_id = fetched.message_sid
      sms.received_time = Time.parse(fetched.time)
      sms.from = fetched.from
      sms.to = fetched.to
      sms.body = fetched.body
    end

    apply SmsSent do |sent|
      sms.twilio_id = sent.message_sid
      sms.sent_time = Time.parse(sent.time)
      sms.from = sent.from
      sms.to = sent.to
      sms.body = sent.body
    end
  end
end
