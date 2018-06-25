# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'sms_component'
  s.version = '0.0.0'
  s.summary = 'Sms Component'
  s.description = ' '

  s.authors = ['The Eventide Project']
  s.email = 'opensource@eventide-project.org'
  s.homepage = 'https://github.com/eventide-examples/sms-component'
  s.licenses = ['MIT']

  s.require_paths = ['lib']
  s.files = Dir.glob('{lib}/**/*')
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.4.0'

  s.add_runtime_dependency 'eventide-postgres'
  s.add_runtime_dependency 'evt-try'
  s.add_runtime_dependency 'ruby-boolean'
  s.add_runtime_dependency 'twilio_lib_client'

  s.add_development_dependency 'test_bench'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'pry-byebug'
end
