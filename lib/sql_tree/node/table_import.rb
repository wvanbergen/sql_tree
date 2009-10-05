module SQLTree::Node
  
  class TableImport < Base
    
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
    
    def self.parse(parser)
      if SQLTree::Token::Variable === parser.peek_token
        table_import = self.new(parser.next_token.literal)
        if parser.peek_token == SQLTree::Token::AS || SQLTree::Token::Variable === parser.peek_token
          parser.consume(SQLTree::Token::AS) if parser.peek_token == SQLTree::Token::AS
          table_import.table_alias = SQLTree::Node::Variable.parse(parser).name
        end

        while [SQLTree::Token::JOIN, SQLTree::Token::LEFT, SQLTree::Token::RIGHT, 
                SQLTree::Token::INNER, SQLTree::Token::OUTER, SQLTree::Token::NATURAL, 
                SQLTree::Token::FULL].include?(parser.peek_token)
              
          table_import.joins << Join.parse(parser)
        end

        return table_import
      else 
        raise SQLTree::Parser::UnexpectedToken.new(peek_token)
      end  
    end
  end 
end
