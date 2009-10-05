module SQLTree::Node
  
  class Join < Base
    
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
    
    def self.parse(tokens)
      join = self.new

      if tokens.peek == SQLTree::Token::FULL
        join.join_type = :outer
        tokens.consume(SQLTree::Token::FULL, SQLTree::Token::OUTER)
      elsif [SQLTree::Token::OUTER, SQLTree::Token::INNER, SQLTree::Token::LEFT, SQLTree::Token::RIGHT].include?(tokens.peek)
        join.join_type = tokens.next.literal.downcase.to_sym
      end

      tokens.consume(SQLTree::Token::JOIN)
      join.table = tokens.next.literal
      if tokens.peek == SQLTree::Token::AS || SQLTree::Token::Variable === tokens.peek
        tokens.consume(SQLTree::Token::AS) if tokens.peek == SQLTree::Token::AS
        join.table_alias = tokens.next.literal
      end

      tokens.consume(SQLTree::Token::ON)
      join.join_expression = SQLTree::Node::Expression.parse(tokens)

      return join      
    end
    
    def ==(other)
      other.table = self.table && other.table_alias == self.table_alias && 
        other.join_type == self.join_type && other.join_expression == self.join_expression
    end
  end
end
