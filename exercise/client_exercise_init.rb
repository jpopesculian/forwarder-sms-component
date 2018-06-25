ENV['CONSOLE_DEVICE'] ||= 'stdout'
ENV['LOG_LEVEL'] = 'info'
ENV['LOG_TAGS'] = '_untagged,-data,messaging,entity_projection,entity_store,ignored'

puts RUBY_DESCRIPTION

require_relative '../client_init'
require 'pry-byebug'
require 'pg'
require 'pp'
require 'twilio_lib_component'

# delete all rows in table
pg_settings = Settings.build('settings/message_store_postgres.json').get
PG::connect(pg_settings).exec('DELETE FROM messages')

# start consumers
TwilioLibComponent::Start.()
SmsComponent::Start.()
