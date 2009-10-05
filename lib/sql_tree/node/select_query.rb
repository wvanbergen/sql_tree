module SQLTree::Node
  
  class SelectQuery < Base
  
    attr_accessor :distinct, :select, :from, :where, :group_by, :having, :order_by, :limit
  
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
  
    # Uses the provided initialized parser to parse a SELECT query.
    def self.parse(tokens)
      select_node = self.new
      tokens.consume(SQLTree::Token::SELECT)

      if tokens.peek == SQLTree::Token::DISTINCT
        tokens.consume(SQLTree::Token::DISTINCT)
        select_node.distinct = true
      end

      select_node.select = self.parse_select_clause(tokens)
      select_node.from   = self.parse_from_clause(tokens)   if tokens.peek == SQLTree::Token::FROM
      select_node.where  = self.parse_where_clause(tokens)  if tokens.peek == SQLTree::Token::WHERE

      return select_node
    end
    
    def self.parse_select_clause(tokens)
      expressions = [SQLTree::Node::SelectExpression.parse(tokens)]
      while tokens.peek == SQLTree::Token::COMMA
        tokens.consume(SQLTree::Token::COMMA)
        expressions << SQLTree::Node::SelectExpression.parse(tokens)
      end
      return expressions
    end
    
    def self.parse_from_clause(tokens)
      tokens.consume(SQLTree::Token::FROM)
      from_expressions = [SQLTree::Node::TableImport.parse(tokens)]
      while tokens.peek == SQLTree::Token::COMMA
        tokens.consume(SQLTree::Token::COMMA)
        from_expressions << SQLTree::Node::TableImport.parse(tokens)
      end

      return from_expressions      
    end
    
    def self.parse_where_clause(tokens)
      tokens.consume(SQLTree::Token::WHERE)
      Expression.parse(tokens)
    end
    
    def self.parse_group_clause(tokens)
    end
    
    def self.parse_having_clause(tokens)
    end
    
    def self.parse_order_clause(tokens)
    end
    
    def self.parse_limit_clause(tokens)
    end
  end
end
