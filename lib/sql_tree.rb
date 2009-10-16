# The SQLTree module is the basic namespace for the sql_tree gem.
#
# It contains the shorthand parse method (i.e. <tt>SQLTree[sql_query]</tt>)
# and some helper methods that are used by the gem. It also requires the
# necessary files for the gem to function properly.
module SQLTree

  class << self
    # The character to quote variable names with.
    attr_accessor :identifier_quote_char
  end
  
  # Set default quote characters
  self.identifier_quote_char = '"'
    
  # Loads constants in the SQLTree namespace using self.load_default_class_file(base, const)
  # <tt>const</tt>:: The constant that is not yet loaded in the SQLTree namespace. This should be passed as a string or symbol.
  def self.const_missing(const)
    load_default_class_file(SQLTree, const)
  end

  # Loads constants that reside in the SQLTree tree using the constant name
  # and its base constant to determine the filename.
  # <tt>base</tt>:: The base constant to load the constant from. This should be Foo when the constant Foo::Bar is being loaded.
  # <tt>const</tt>:: The constant to load from the base constant as a string or symbol. This should be 'Bar' or :Bar when the constant Foo::Bar is being loaded.
  def self.load_default_class_file(base, const)
    require "#{to_underscore("#{base.name}::#{const}")}"
    base.const_get(const) if base.const_defined?(const)
  end

  # The <tt>[]</tt> method is a shorthand for the <tt>SQLTree::Parser.parse</tt>
  # method to parse an SQL query and return a SQL syntax tree.
  def self.[](query, options = {})
    SQLTree::Parser.parse(query)
  end

  # Convert a string/symbol in camelcase (SQLTree::Parser) to underscores (sql_tree/parser)
  # This function can be used to load the file (using require) in which the given constant is defined.
  # <tt>str</tt>:: The string to convert in the following format: <tt>ModuleName::ClassName</tt>
  def self.to_underscore(str)
    str.to_s.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
  end

  # Convert a string/symbol in underscores (<tt>sql_tree/parser</tt>) to camelcase
  # (<tt>SqlTree::Parser</tt>). This can be used to find the class that is defined in a given filename.
  # <tt>str</tt>:: The string to convert in the following format: <tt>module_name/class_name</tt>
  def self.to_camelcase(str)
    str.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
  end
end
