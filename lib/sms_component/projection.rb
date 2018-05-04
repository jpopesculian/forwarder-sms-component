module SmsComponent
  class Projection
    include EntityProjection
    include Messages::Events

    entity_name :sms

    apply SmsFetched do |fetched|
      sms.message_sid = fetched.message_sid
      sms.received_time = Time.parse(fetched.time)
      sms.from = fetched.from
      sms.to = fetched.to
      sms.body = fetched.body
    end
  end
end
