module SmsComponent
  module Consumers
    class Replies
      include Consumer::Postgres

      handler Handlers::Replies
    end
  end
end
