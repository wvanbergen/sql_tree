module SQLTree::Node

  class UpdateQuery < Base
    
    attr_accessor :table, :updates, :where
    
    def initialize(table, updates = [], where = nil)
      @table, @updates, @where = table, updates, where
    end
    
    def to_sql
      sql = "UPDATE #{self.quote_var(table)} SET "
      sql << updates.map { |u| u.to_sql }.join(', ')
      sql << " WHERE " << where.to_sql if self.where
      sql
    end
    
    def self.parse(tokens)
      tokens.consume(SQLTree::Token::UPDATE)
      update_query = self.new(SQLTree::Node::Variable.parse(tokens).name)
      tokens.consume(SQLTree::Token::SET)
      update_query.updates = [SQLTree::Node::Assignment.parse(tokens)]
      while SQLTree::Token::COMMA === tokens.peek
        tokens.consume(SQLTree::Token::COMMA)
        update_query.updates << SQLTree::Node::Assignment.parse(tokens)
      end
      
      if SQLTree::Token::WHERE === tokens.peek
        tokens.consume(SQLTree::Token::WHERE)
        update_query.where = SQLTree::Node::Expression.parse(tokens)
      end
      
      update_query
    end
  end
end
