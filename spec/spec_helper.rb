$:.reject! { |e| e.include? 'TextMate' }
$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'spec'
require 'sql_tree'

module SQLTree::Spec
  module NodeLoader
    def self.const_missing(const)
      SQLTree::Node.const_get(const)
    end
  end
  
  module TokenLoader
    def self.const_missing(const)
      SQLTree::Token.const_get(const)
    end
  end  
end

Spec::Runner.configure do |config|
  
end

require "#{File.dirname(__FILE__)}/lib/matchers"
