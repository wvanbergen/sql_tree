module SQLTree
  def self.[](query, options = {:as => :query})
    SQLTree::Parser.parse(query)
  end
  
  # Convert a string/symbol in camelcase (RequestLogAnalyzer::Controller) to underscores (request_log_analyzer/controller)
  # This function can be used to load the file (using require) in which the given constant is defined.
  # <tt>str</tt>:: The string to convert in the following format: <tt>ModuleName::ClassName</tt>
  def self.to_underscore(str)
    str.to_s.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
  end

  # Convert a string/symbol in underscores (<tt>request_log_analyzer/controller</tt>) to camelcase
  # (<tt>RequestLogAnalyzer::Controller</tt>). This can be used to find the class that is defined in a given filename.
  # <tt>str</tt>:: The string to convert in the following format: <tt>module_name/class_name</tt>
  def self.to_camelcase(str)
    str.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
  end  
end

require 'sql_tree/token'
require 'sql_tree/tokenizer'
require 'sql_tree/parser'

require 'sql_tree/node'
require 'sql_tree/node/select_query'
require 'sql_tree/node/expression'
require 'sql_tree/node/leafs'

require 'sql_tree/generator'
