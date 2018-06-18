ENV['CONSOLE_DEVICE'] ||= 'stdout'
ENV['LOG_LEVEL'] = 'info'
ENV['LOG_TAGS'] = '_untagged,-data,messaging,entity_projection,entity_store,ignored'

puts RUBY_DESCRITPION

require_relative '../client_init'
require 'pry-byebug'

require 'pp'
