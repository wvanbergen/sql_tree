class SQLTree::Node

  def inspect
    "#{self.class.name}[#{self.to_sql}]"
  end
  
  def quote_var(name)
    "\"#{name}\""
  end
  
  def quote_str(str)
    "'#{str.gsub(/\'/, "''")}'"
  end
  
  def self.[](sql, options = {})
    options[:as] = :"#{SQLTree.to_underscore(self.name.split('::').last)}"
    SQLTree::Parser.parse(sql, options)
  end
end
