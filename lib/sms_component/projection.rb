module SmsComponent
  class Projection
    include EntityProjection
    include Messages::Events

    entity_name :sms

    apply SmsFetched do |fetched|
      sms.id = fetched.sms_id
      sms.twilio_id = fetched.message_sid
      sms.received_time = Time.parse(fetched.time)
      sms.from = fetched.from
      sms.to = fetched.to
      sms.body = fetched.body
    end

    apply SmsDelivered do |delivered|
      sms.id = delivered.sms_id
      sms.twilio_id = delivered.message_sid
      sms.sent_time = Time.parse(delivered.time)
      sms.from = delivered.from
      sms.to = delivered.to
      sms.body = delivered.body
    end
  end
end
