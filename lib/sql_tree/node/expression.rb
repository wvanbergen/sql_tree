module SQLTree::Node

  # Base class for all SQL expressions.
  #
  # This is an asbtract class and should not be used directly. Use
  # one of the subclasses instead.
  class Expression < Base

    def self.parse(tokens)
      SQLTree::Node::LogicalExpression.parse(tokens)
    end

    # Parses a single, atomic SQL expression. This can be either:
    # * a full expression (or set of expressions) within parentheses.
    # * a logical NOT expression
    # * an SQL variable
    # * an SQL function
    # * a literal SQL value (numeric or string)
    def self.parse_atomic(tokens)
      case tokens.peek
      when SQLTree::Token::LPAREN
        tokens.consume(SQLTree::Token::LPAREN)
        expr = SQLTree::Node::Expression.parse(tokens)
        tokens.consume(SQLTree::Token::RPAREN)
        expr
      when SQLTree::Token::NOT
        SQLTree::Node::LogicalNotExpression.parse(tokens)
      when SQLTree::Token::Variable
        if tokens.peek(2) == SQLTree::Token::LPAREN
          SQLTree::Node::FunctionExpression.parse(tokens)
        else
          SQLTree::Node::Variable.parse(tokens)
        end
      else
        SQLTree::Node::Value.parse(tokens)
      end
    end
  end

  class LogicalNotExpression < Expression

    attr_accessor :expression

    def initialize(expression)
      @expression = expression
    end

    def to_sql
      "NOT(#{@expression.to_sql})"
    end

    def ==(other)
      other.kind_of?(self.class) && other.expression == self.expression
    end

    def self.parse(tokens)
      tokens.consume(SQLTree::Token::NOT)
      self.new(SQLTree::Node::Expression.parse(tokens))
    end
  end

  class LogicalExpression < Expression
    attr_accessor :operator, :expressions

    def initialize(operator, expressions)
      @expressions = expressions
      @operator    = operator.to_s.downcase.to_sym
    end

    def to_sql
      "(" + @expressions.map { |e| e.to_sql }.join(" #{@operator.to_s.upcase} ") + ")"
    end

    def ==(other)
      self.operator == other.operator && self.expressions == other.expressions
    end

    def self.parse(tokens)
      expr = ComparisonExpression.parse(tokens)
      while [SQLTree::Token::AND, SQLTree::Token::OR].include?(tokens.peek)
        expr = SQLTree::Node::LogicalExpression.new(tokens.next.literal, [expr, ComparisonExpression.parse(tokens)])
      end
      return expr
    end
  end

  class ComparisonExpression < Expression
    attr_accessor :lhs, :rhs, :operator

    def initialize(operator, lhs, rhs)
      @lhs = lhs
      @rhs = rhs
      @operator = operator
    end

    def to_sql
      "(#{@lhs.to_sql} #{@operator} #{@rhs.to_sql})"
    end

    def self.parse_comparison_operator(tokens)
      operator_token = tokens.next
      if SQLTree::Token::IS === operator_token
        if SQLTree::Token::NOT === tokens.peek
          tokens.consume(SQLTree::Token::NOT)
          'IS NOT'
        else
          'IS'
        end
      elsif SQLTree::Token::NOT === operator_token
        case tokens.peek
        when SQLTree::Token::LIKE, SQLTree::Token::ILIKE, SQLTree::Token::BETWEEN, SQLTree::Token::IN
          "NOT #{tokens.next.literal.upcase}"
        else
          raise SQLTree::Parser::UnexpectedToken.new(tokens.peek)
        end
      else
        operator_token.literal
      end
    end

    def self.parse(tokens)
      lhs = SQLTree::Node::ArithmeticExpression.parse(tokens)
      while SQLTree::Token::COMPARISON_OPERATORS.include?(tokens.peek)
        comparison_operator = parse_comparison_operator(tokens)
        rhs = ['IN', 'NOT IN'].include?(comparison_operator) ?
                SQLTree::Node::SetExpression.parse(tokens)   :
                SQLTree::Node::ArithmeticExpression.parse(tokens)

        lhs = self.new(comparison_operator, lhs, rhs)
      end
      return lhs
    end
  end

  class SetExpression < Expression
    attr_accessor :items

    def initialize(items = [])
      @items = items
    end

    def to_sql
      "(#{items.map {|i| i.to_sql}.join(', ')})"
    end

    def self.parse(tokens)
      tokens.consume(SQLTree::Token::LPAREN)
      items = [SQLTree::Node::Expression.parse(tokens)]
      while tokens.peek == SQLTree::Token::COMMA
        tokens.consume(SQLTree::Token::COMMA)
        items << SQLTree::Node::Expression.parse(tokens)
      end
      tokens.consume(SQLTree::Token::RPAREN)

      self.new(items)
    end
  end

  class FunctionExpression < Expression
    attr_accessor :function, :arguments

    def initialize(function, arguments = [])
      @function = function
      @arguments = arguments
    end

    def to_sql
      "#{@function}(" + @arguments.map { |e| e.to_sql }.join(', ') + ")"
    end

    def self.parse(tokens)
      expr = self.new(tokens.next.literal)
      tokens.consume(SQLTree::Token::LPAREN)
      until tokens.peek == SQLTree::Token::RPAREN
        expr.arguments << SQLTree::Node::Expression.parse(tokens)
        tokens.consume(SQLTree::Token::COMMA) if tokens.peek == SQLTree::Token::COMMA
      end
      tokens.consume(SQLTree::Token::RPAREN)
      return expr
    end
  end

  class ArithmeticExpression < Expression
    attr_accessor :lhs, :rhs, :operator

    def initialize(operator, lhs, rhs)
      @lhs = lhs
      @rhs = rhs
      @operator = operator
    end

    def to_sql
      "(#{@lhs.to_sql} #{@operator} #{@rhs.to_sql})"
    end

    def self.parse(tokens)
      self.parse_primary(tokens)
    end

    def self.parse_primary(tokens)
      expr = self.parse_secondary(tokens)
      while [SQLTree::Token::PLUS, SQLTree::Token::MINUS].include?(tokens.peek)
        expr = self.new(tokens.next.literal, expr, self.parse_secondary(tokens))
      end
      return expr
    end

    def self.parse_secondary(tokens)
      expr = Expression.parse_atomic(tokens)
      while [SQLTree::Token::PLUS, SQLTree::Token::MINUS].include?(tokens.peek)
        expr = self.new(tokens.next.literal, expr, SQLTree::Node::Expression.parse_atomic(tokens))
      end
      return expr
    end
  end
end
