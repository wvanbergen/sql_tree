module SQLTree::Node

  class InsertQuery < Base

    child :table
    
    child :fields
    
    child :values

    def initialize(table, fields = nil, values = [])
      @table, @fields, @values  = table, fields, values
    end

    def to_sql(options = {})
      sql = "INSERT INTO #{table.to_sql(options)} "
      sql << '(' + fields.map { |f| f.to_sql(options) }.join(', ') + ') ' if fields
      sql << 'VALUES (' + values.map { |v| v.to_sql(options) }.join(', ') + ')'
      sql
    end
    
    def self.parse_field_list(tokens)
      tokens.consume(SQLTree::Token::LPAREN)
      fields = parse_list(tokens, SQLTree::Node::Expression::Field)
      tokens.consume(SQLTree::Token::RPAREN)
      return fields
    end
    
    def self.parse_value_list(tokens)
      tokens.consume(SQLTree::Token::VALUES)
      tokens.consume(SQLTree::Token::LPAREN)
      values = parse_list(tokens)
      tokens.consume(SQLTree::Token::RPAREN)
      return values
    end
    
    def self.parse(tokens)
      tokens.consume(SQLTree::Token::INSERT)
      tokens.consume(SQLTree::Token::INTO)
      insert_query = self.new(SQLTree::Node::TableReference.parse(tokens))

      insert_query.fields = self.parse_field_list(tokens) if SQLTree::Token::LPAREN === tokens.peek
      insert_query.values = self.parse_value_list(tokens)
      return insert_query
    end
  end
end
