module SQLTree::Node

  class DeleteQuery < Base

    attr_accessor :table, :expression

    def initialize(table, expression = nil)
      @table, @expression = table, expression
    end

    def to_sql
      sql = "DELETE FROM #{self.quote_var(table)}"
      sql << " WHERE #{expression.to_sql}" if self.expression
      sql
    end
    
    def self.parse(tokens)
      tokens.consume(SQLTree::Token::DELETE)
      tokens.consume(SQLTree::Token::FROM)
      delete_query = self.new(SQLTree::Node::Variable.parse(tokens).name)
      if tokens.peek == SQLTree::Token::WHERE
        tokens.consume(SQLTree::Token::WHERE)
        delete_query.expression = SQLTree::Node::Expression.parse(tokens)
      end
      return delete_query
    end
  end
end
