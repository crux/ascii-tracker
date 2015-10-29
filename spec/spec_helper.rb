$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'asciitracker'
begin
  require 'byebug'
rescue LoadError
  puts " !! no byebug on #{RUBY_PLATFORM}(#{RUBY_VERSION}) ;-)"
end

RSpec.configure do |config|
  config.before :each do
  end

  config.after :each do
  end
end
