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
    
    def self.parse(tokens)
      if SQLTree::Token::Variable === tokens.peek
        table_import = self.new(tokens.next.literal)
        if tokens.peek == SQLTree::Token::AS || SQLTree::Token::Variable === tokens.peek
          tokens.consume(SQLTree::Token::AS) if tokens.peek == SQLTree::Token::AS
          table_import.table_alias = SQLTree::Node::Variable.parse(tokens).name
        end

        while [SQLTree::Token::JOIN, SQLTree::Token::LEFT, SQLTree::Token::RIGHT, 
                SQLTree::Token::INNER, SQLTree::Token::OUTER, SQLTree::Token::NATURAL, 
                SQLTree::Token::FULL].include?(tokens.peek)
              
          table_import.joins << Join.parse(tokens)
        end

        return table_import
      else 
        raise SQLTree::Parser::UnexpectedToken.new(tokens.peek)
      end  
    end
  end 
end
