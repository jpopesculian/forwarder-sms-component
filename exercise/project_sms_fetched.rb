require_relative './exercise_init'

message_sid = "SM167c72b00640f6f1885b34960e16c568"

sms_fetched = SmsComponent::Messages::Events::SmsFetched.new
sms_fetched.message_sid = message_sid
sms_fetched.time = "2018-05-03T18:53:57+00:00"
sms_fetched.from = "+4368184385820"
sms_fetched.to = "+4915735995854"
sms_fetched.body = "Hallo"

stream_name = "sms-#{message_sid}"

Messaging::Postgres::Write.(sms_fetched, stream_name)

sms = SmsComponent::Sms.new

puts "New Sms #{sms.message_sid} from: #{sms.to} to: #{sms.from} body: #{sms.body}"

MessageStore::Postgres::Read.(stream_name) do |message_data|
  SmsComponent::Projection.(sms, message_data)
end

puts "Sms #{sms.message_sid} from: #{sms.to} to: #{sms.from} body: #{sms.body}"
