class SQLTree::Node
  class Value < SQLTree::Node

    attr_accessor :value

    def initialize(value)
      @value = value
    end
  
    def to_sql
      @value.kind_of?(String) ? quote_str(@value) : @value.to_s
    end
    
    def to_tree
      @value
    end
    
    def eql?(other)
      other.kind_of?(self.class) && other.value.eql?(@value)
    end
  end  

  class Variable < SQLTree::Node

    attr_accessor :name

    def initialize(name)
      @name = name
    end
  
    def to_sql
      quote_var(@name)
    end
    
    def to_tree
      @name.to_sym
    end
    
    def eql?(other)
      other.kind_of?(self.class) && other.name.eql?(@name)
    end
    

    
  end

  class Field < SQLTree::Node

    attr_accessor :name, :table

    def initialize(name, table = nil)
      @name = name
      @table = table
    end
    
    def self.[](table, field)
      self.new(field.to_s, table.to_s)
    end
  
    def quote_var(name)
      return '*' if name == :all
      super(name)
    end
  
    def to_sql
      @table.nil? ? quote_var(@name) : quote_var(@table) + '.' + quote_var(@name)
    end
    
    def eql?(other)
      other.kind_of?(self.class) && other.name.eql?(@name) && other.table.eql?(@table)
    end
    
    def to_tree
      to_sql.to_sym
    end    
    
  end
end