module SQLTree::Node

  class TableReference < Base

    leaf :table
    leaf :table_alias

    def initialize(table, table_alias = nil)
      @table, @table_alias = table, table_alias
    end

    def to_sql(options = {})
      sql = quote_var(table)
      sql << " AS " << quote_var(table_alias) if table_alias
      return sql
    end

    def self.parse(tokens)
      if SQLTree::Token::Identifier === tokens.next
        table_reference = self.new(tokens.current.literal)
        if SQLTree::Token::AS === tokens.peek || SQLTree::Token::Identifier === tokens.peek
          tokens.consume(SQLTree::Token::AS) if SQLTree::Token::AS === tokens.peek
          table_reference.table_alias = tokens.next.literal
        end
        return table_reference
      else
        raise SQLTree::Parser::UnexpectedToken.new(tokens.current)
      end
    end
  end
end
