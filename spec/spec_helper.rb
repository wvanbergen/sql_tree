$:.reject! { |e| e.include? 'TextMate' }
$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'spec'
require 'sql_tree'

module SQLTree::Spec
end

require "#{File.dirname(__FILE__)}/lib/matchers"
