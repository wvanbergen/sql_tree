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
    def self.parse(parser)
      select_node = self.new
      parser.consume(SQLTree::Token::SELECT)

      if parser.peek_token == SQLTree::Token::DISTINCT
        parser.consume(SQLTree::Token::DISTINCT)
        select_node.distinct = true
      end

      select_node.select = self.parse_select_clause(parser)
      select_node.from   = self.parse_from_clause(parser)   if parser.peek_token == SQLTree::Token::FROM
      select_node.where  = self.parse_where_clause(parser)  if parser.peek_token == SQLTree::Token::WHERE

      return select_node
    end
    
    def self.parse_select_clause(parser)
      expressions = [SQLTree::Node::SelectExpression.parse(parser)]
      while parser.peek_token == SQLTree::Token::COMMA
        parser.consume(SQLTree::Token::COMMA)
        expressions << SQLTree::Node::SelectExpression.parse(parser)
      end
      return expressions
    end
    
    def self.parse_from_clause(parser)
      parser.consume(SQLTree::Token::FROM)
      from_expressions = [SQLTree::Node::TableImport.parse(parser)]
      while parser.peek_token == SQLTree::Token::COMMA
        parser.consume(SQLTree::Token::COMMA)
        from_expressions << SQLTree::Node::TableImport.parse(parser)
      end

      return from_expressions      
    end
    
    def self.parse_where_clause(parser)
      parser.consume(SQLTree::Token::WHERE)
      Expression.parse(parser)
    end
    
    def self.parse_group_clause(parser)
    end
    
    def self.parse_having_clause(parser)
    end
    
    def self.parse_order_clause(parser)
    end
    
    def self.parse_limit_clause(parser)
    end
  end
end
