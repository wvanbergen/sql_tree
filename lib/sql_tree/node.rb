module SQLTree::Node

  def self.const_missing(const)
    SQLTree.load_default_class_file(SQLTree::Node, const)
  end

  class Base

    # Pretty prints this instance for inspection
    def inspect
      "#{self.class.name}[#{self.to_sql}]"
    end
  
    # Quotes a variable name so that it can be safely used within 
    # SQL queries.
    def quote_var(name)
      "\"#{name}\""
    end
  
    # Quotes a string so that it can be used within an SQL query.
    def quote_str(str)
      "'#{str.gsub(/\'/, "''")}'"
    end
  
    # This method should be implemented by a subclass.
    def self.parse(parser)
      raise 'Only implemented in subclasses!'
    end
  
    # Parses a string, expecting it to be parsable to an instance of
    # the current class.
    def self.[](sql, options = {})
      parser = SQLTree::Parser.new(sql, options)
      self.parse(parser)
    end
  end
end