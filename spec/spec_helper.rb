require 'rubygems'
require 'bundler'

Bundler.require(:default)

# Load helper files.
Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Nothing special going on
end
