module SmsComponent
  class Projection
    include EntityProjection
    include Messages::Events

    entity_name :sms

    apply SmsFetched do |fetched|
      sms.id = fetched.sms_id
      sms.twilio_id = fetched.message_sid
      sms.from = fetched.from
      sms.to = fetched.to
      sms.body = fetched.body
      sms.status = fetched.status
      sms.set_time fetched.time, fetched.direction
    end

    apply SmsDelivered do |delivered|
      sms.id = delivered.sms_id
      sms.twilio_id = delivered.message_sid
      sms.from = delivered.from
      sms.to = delivered.to
      sms.body = delivered.body
      sms.status_callback = delivered.status_callback
      sms.status = "sending"
      sms.set_time delivered.time, "outbound"
    end
  end
end
