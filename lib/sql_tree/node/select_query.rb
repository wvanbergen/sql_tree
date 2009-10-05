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
      sql << " WHERE " << where.to_sql if where
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
      sql = @expression.to_sql
      sql << " AS " << quote_var(@variable) if @variable
      return sql
    end
    
    def ==(other)
      other.expression == self.expression && other.variable == self.variable
    end
  end
  
  class TableImport < SQLTree::Node
    
    attr_accessor :table, :table_alias, :joins
    
    def initialize(table, table_alias = nil, joins = [])
      @table, @table_alias, @joins = table, table_alias, joins
    end
  
    def to_sql
      sql = quote_var(table)
      sql << " AS " << quote_var(table_alias) if table_alias
      return sql
    end
    
    def ==(other)
      other.table = self.table && other.table_alias == self.table_alias && other.joins == self.joins
    end
  end
  
  class Join < SQLTree::Node
    
    attr_accessor :join_type, :table, :table_alias, :join_expression
    
    def initialize(values = {})
      values.each { |key, value| self.send(:"#{key}=", value) }
    end
    
    def to_sql
      join_sql = join_type ? "#{join_type.to_s.upcase} " : ""
      join_sql << "JOIN #{table} "
      join_sql << "AS #{table_alias} " if table_alias
      join_sql << "ON #{join_expression.to_sql}"
      join_sql
    end
    
    def ==(other)
      other.table = self.table && other.table_alias == self.table_alias && 
        other.join_type == self.join_type && other.join_expression == self.join_expression
    end
  end
end
