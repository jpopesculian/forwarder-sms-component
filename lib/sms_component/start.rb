module SmsComponent
  module Start
    def self.call
      Consumers::Commands.start('sms:command')
      Consumers::Events.start('sms')
      Consumers::Replies.start('sms:command')
    end
  end
end
