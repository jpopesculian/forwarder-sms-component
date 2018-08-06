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
      sms.set_direction fetched.direction
      sms.set_time fetched.time
      sms.meta_position = fetched.meta_position
    end

    apply SmsDelivered do |delivered|
      sms.id = delivered.sms_id
      sms.twilio_id = delivered.message_sid
      sms.from = delivered.from
      sms.to = delivered.to
      sms.body = delivered.body
      sms.status_callback = delivered.status_callback
      sms.status = "sending"
      sms.set_direction Sms::INBOUND_DIRECTION
      sms.set_time delivered.time
      sms.meta_position = delivered.meta_position
    end

    apply SmsForwardInitiated do |initiated|
      sms.id = initiated.sms_id
      sms.meta_position = initiated.meta_position
    end

    apply SmsDeliverInitiated do |initiated|
      sms.id = initiated.sms_id
      sms.meta_position = initiated.meta_position
    end

    apply SmsUpdated do |updated|
      sms.id = updated.sms_id
      sms.meta_position = updated.meta_position
    end
  end
end
