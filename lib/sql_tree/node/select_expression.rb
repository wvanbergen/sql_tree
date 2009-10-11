module SQLTree::Node

  class SelectExpression < Base

    attr_accessor :expression, :variable

    def initialize(expression, variable = nil)
      @expression = expression
      @variable   = variable
    end

    def to_sql
      sql = @expression.to_sql
      sql << " AS " << quote_var(@variable) if @variable
      return sql
    end

    def self.parse(tokens)
      if SQLTree::Token::MULTIPLY === tokens.peek
        tokens.consume(SQLTree::Token::MULTIPLY)
        return SQLTree::Node::ALL_FIELDS
      else
        expression = SQLTree::Node::Expression.parse(tokens)
        expr = SQLTree::Node::SelectExpression.new(expression)
        if SQLTree::Token::AS === tokens.peek
          tokens.consume(SQLTree::Token::AS)
          expr.variable = SQLTree::Node::Variable.parse(tokens).name
        end
        return expr
      end
    end

    def ==(other)
      other.expression == self.expression && other.variable == self.variable
    end
  end

  class AllFieldsExpression < Expression
    def to_sql
      '*'
    end
  end

  ALL_FIELDS = AllFieldsExpression.new
end
