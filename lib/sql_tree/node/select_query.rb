class SQLTree::Node
  
  class SelectQuery < SQLTree::Node
  
    attr_accessor :distinct, :select, :from, :where, :group_by, :having, :order_by
  
    def initialize
      @distinct = false
      @select   = []
    end
  
    def to_sql
      raise "At least one SELECT expression is required" if self.select.empty?
      sql = (self.distinct) ? "SELECT DISTINCT " : "SELECT "
      sql << select.map { |s| s.to_sql }.join(', ')
      sql << " FROM " << from.map { |f| f.to_sql }.join(', ')      
      return sql
    end
  
  end
  
  class SelectExpression < SQLTree::Node
    
    attr_accessor :expression, :variable
    
    def initialize(expression, variable = nil)
      @expression = expression
      @variable   = variable
    end
    
    def to_sql
      sql = @expression == '*' ? '*' : @expression.to_sql
      sql << " AS " << quote_var(@variable) if @variable
      return sql
    end
    
  end
  
  class TableImport < SQLTree::Node
    
    attr_accessor :table, :variable
    
    def initialize(table, variable = nil)
      @table    = table
      @variable = variable
    end
  
    def to_sql
      sql = quote_var(@table)
      sql << " AS " << quote_var(@variable) if @variable
      return sql
    end
  
  end
  
end