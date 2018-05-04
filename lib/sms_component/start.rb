module SmsComponent
  module Start
    def self.call
      Consumers::Commands.start('sms:command')
      Consumers::Events.start('sms')
    end
  end
end
