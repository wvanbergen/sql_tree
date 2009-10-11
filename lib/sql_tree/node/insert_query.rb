module SQLTree::Node

  class InsertQuery < Base

    attr_accessor :table, :fields, :values

    def initialize(table, fields = nil, values = [])
      @table, @fields, @values  = table, fields, values
    end

    def to_sql
      sql = "INSERT INTO #{self.quote_var(table)} "
      sql << '(' + fields.map { |f| f.to_sql }.join(', ') + ') ' if fields
      sql << 'VALUES (' + values.map { |v| v.to_sql }.join(', ') + ')'
      sql
    end
    
    def self.parse_field_list(tokens)
      tokens.consume(SQLTree::Token::LPAREN)
      fields = [SQLTree::Node::Variable.parse(tokens)]
      while SQLTree::Token::COMMA === tokens.peek
        tokens.consume(SQLTree::Token::COMMA)
        fields << SQLTree::Node::Variable.parse(tokens)
      end
      tokens.consume(SQLTree::Token::RPAREN)
      return fields
    end
    
    def self.parse_value_list(tokens)
      tokens.consume(SQLTree::Token::VALUES)
      tokens.consume(SQLTree::Token::LPAREN)
      values = [SQLTree::Node::Expression.parse(tokens)]
      while SQLTree::Token::COMMA === tokens.peek
        tokens.consume(SQLTree::Token::COMMA)
        values << SQLTree::Node::Expression.parse(tokens)
      end
      tokens.consume(SQLTree::Token::RPAREN)
      return values
    end
    
    def self.parse(tokens)
      tokens.consume(SQLTree::Token::INSERT)
      tokens.consume(SQLTree::Token::INTO)
      insert_query = self.new(SQLTree::Node::Variable.parse(tokens).name)

      insert_query.fields = self.parse_field_list(tokens) if SQLTree::Token::LPAREN === tokens.peek
      insert_query.values = self.parse_value_list(tokens)
      return insert_query
    end
  end
end
