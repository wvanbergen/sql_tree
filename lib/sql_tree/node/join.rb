module SQLTree::Node

  class Join < Base

    leaf :join_type
    child :table_reference
    child :join_expression

    def initialize(values = {})
      values.each { |key, value| self.send(:"#{key}=", value) }
    end

    def to_sql(options = {})
      join_sql = join_type ? "#{join_type.to_s.upcase} " : ""
      join_sql << "JOIN #{table_reference.to_sql(options)} "
      join_sql << "ON #{join_expression.to_sql(options)}"
      join_sql
    end

    def table
      table_reference.table
    end

    def table_alias
      table_reference.table_alias
    end

    def self.parse(tokens)
      join = self.new

      if SQLTree::Token::FULL === tokens.peek
        join.join_type = :outer
        tokens.consume(SQLTree::Token::FULL, SQLTree::Token::OUTER)
      elsif [SQLTree::Token::OUTER, SQLTree::Token::INNER, SQLTree::Token::LEFT, SQLTree::Token::RIGHT].include?(tokens.peek.class)
        join.join_type = tokens.next.literal.downcase.to_sym
      end

      tokens.consume(SQLTree::Token::JOIN)
      join.table_reference = SQLTree::Node::TableReference.parse(tokens)
      tokens.consume(SQLTree::Token::ON)
      join.join_expression = SQLTree::Node::Expression.parse(tokens)

      return join
    end
  end
end
