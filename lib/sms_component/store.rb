module SmsComponent
  class Store
    include EntityStore

    category :sms
    entity Sms
    projection Projection
    reader MessageStore::Postgres::Read
  end
end
