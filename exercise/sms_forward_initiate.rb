require_relative './client_exercise_init'

message_sid = "SM167c72b00640f6f1885b34960e16c568"

command = Sms::Client::SmsForward.(
  message_sid: message_sid
)

while true do
  sleep 5
end

