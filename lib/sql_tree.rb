# The SQLTree module is the basic namespace for the sql_tree gem.
#
# It contains the shorthand parse method (i.e. <tt>SQLTree[sql_query]</tt>)
# and some helper methods that are used by the gem. It also requires the
# necessary files for the gem to function properly.
module SQLTree

  VERSION = "0.1.1"

  class << self
    # The character to quote variable names with.
    attr_accessor :identifier_quote_char
  end
  
  # Set default quote characters
  self.identifier_quote_char = '"'
    
  # The <tt>[]</tt> method is a shorthand for the <tt>SQLTree::Parser.parse</tt>
  # method to parse an SQL query and return a SQL syntax tree.
  def self.[](query, options = {})
    SQLTree::Parser.parse(query)
  end
end

require 'sql_tree/token'
require 'sql_tree/tokenizer'
require 'sql_tree/node'
require 'sql_tree/parser'