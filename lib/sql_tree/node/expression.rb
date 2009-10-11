module SQLTree::Node

  # Abstract base class for all SQL expressions.
  #
  # To parse a string as an SQL expression, use:
  #
  #   SQLTree::Node::Expression["(3 + 2 = 10 / 2) AND MD5('$ecret') = password"]
  #
  # This is an abtract class: its parse method will never return an
  # <tt>SQLTree::Node::Expression</tt> instance, but always an instance
  # of one of its subclasses.
  class Expression < Base

    # Parses an SQL expression from a stream of tokens.
    #
    # This method will start trying to parse the token stream as a 
    # <tt>SQLTree::Node::LogicalExpression</tt>, which will in turn try to parse it as other
    # kinds of expressions if a logical expression is not appropriate.
    #
    # <tt>tokens</tt>:: The token stream to parse from, which is an instance
    #                   of <tt> SQLTree::Parser</tt>.
    def self.parse(tokens)
      SQLTree::Node::Expression::BinaryOperator.parse(tokens)
    end

    # Parses a single, atomic SQL expression. This can be either:
    # * a full expression (or set of expressions) within parentheses.
    # * a logical NOT expression
    # * an SQL variable
    # * an SQL function
    # * a literal SQL value (numeric or string)
    #
    # <tt>tokens</tt>:: The token stream to parse from, which is an instance
    #                   of <tt> SQLTree::Parser</tt>.
    def self.parse_atomic(tokens)
      if SQLTree::Token::LPAREN === tokens.peek
        tokens.consume(SQLTree::Token::LPAREN)
        expr = self.parse(tokens)
        tokens.consume(SQLTree::Token::RPAREN)
        expr
      elsif tokens.peek.prefix_operator?
        PrefixOperator.parse(tokens)
      elsif tokens.peek.variable?
        if SQLTree::Token::LPAREN === tokens.peek(2)
          Function.parse(tokens)
        else
          SQLTree::Node::Variable.parse(tokens)
        end
      else
        SQLTree::Node::Value.parse(tokens)
      end
    end
    
    class PrefixOperator < self
      
      TOKENS = [SQLTree::Token::NOT]
      
      attr_accessor :operator
      attr_accessor :rhs
      
      def to_sql
        "#{operator.upcase} #{rhs.to_sql}"
      end
      
      def ==(other) # :nodoc:
        self.class == other.class && self.rhs == other.rhs &&
          self.operator.upcase == other.operator.upcase
      end
      
      def self.parse_operator(tokens)
        tokens.next.literal
      end
      
      def self.parse(tokens)
        if tokens.peek.prefix_operator?
          node = self.new
          node.operator   = parse_operator(tokens)
          node.rhs        = SQLTree::Node::Expression.parse(tokens)
          return node
        else
          raise UnexpectedTokenException.new(tokens.peek)
        end
      end
    end
    
    class PostfixOperator < self
      
      attr_accessor :operator
      attr_accessor :lhs
      
      def self.parse(tokens)
      end
    end
    
    class BinaryOperator < self
      
      # The token precedence list
      # The token precedence list is taken from the SQLite3 documentation.
      TOKEN_PRECEDENCE = [
          [SQLTree::Token::OR],
          [SQLTree::Token::AND],
          [SQLTree::Token::EQ, SQLTree::Token::NE, SQLTree::Token::IN, SQLTree::Token::LIKE, SQLTree::Token::ILIKE, SQLTree::Token::IS],
          [SQLTree::Token::LT, SQLTree::Token::LTE, SQLTree::Token::GT, SQLTree::Token::GTE],
          [SQLTree::Token::LSHIFT, SQLTree::Token::RSHIFT, SQLTree::Token::BINARY_AND, SQLTree::Token::BINARY_OR],
          [SQLTree::Token::PLUS, SQLTree::Token::MINUS],
          [SQLTree::Token::MULTIPLY, SQLTree::Token::DIVIDE, SQLTree::Token::MODULO],
          [SQLTree::Token::CONCAT],
        ]
      
      TOKENS = TOKEN_PRECEDENCE.flatten
      
      attr_accessor :operator
      attr_accessor :lhs
      attr_accessor :rhs
      
      def to_sql
        "(#{lhs.to_sql} #{operator} #{rhs.to_sql})"
      end
      
      def ==(other)
        self.class == other.class && self.operator == other.operator &&
          self.lhs == other.lhs && self.rhs == other.rhs
      end
      
      def self.parse_operator(tokens)
        if tokens.peek.optional_not_suffix? && tokens.peek(2).not?
          return "#{tokens.next.literal.upcase} #{tokens.next.literal.upcase}"
        elsif tokens.peek.not? && tokens.peek(2).optional_not_prefix?
          return "#{tokens.next.literal.upcase} #{tokens.next.literal.upcase}"
        else
          return tokens.next.literal.upcase
        end
      end
    
      def self.parse_rhs(tokens, level, operator = nil)
        if ['IN', 'NOT IN'].include?(operator)
          return List.parse(tokens)
        elsif ['IS', 'IS NOT'].include?(operator)
          tokens.consume(SQLTree::Token::NULL)
          return SQLTree::Node::Value.new(nil)
        else
          return parse(tokens, level + 1)
        end
      end
      
      def self.parse(tokens, level = 0)
        if level >= TOKEN_PRECEDENCE.length
          return SQLTree::Node::Expression.parse_atomic(tokens)
        else
          expr = parse(tokens, level + 1)
          while TOKEN_PRECEDENCE[level].include?(tokens.peek.class) || (tokens.peek && tokens.peek.not?)
            operator = parse_operator(tokens)
            rhs      = parse_rhs(tokens, level, operator)
            expr     = self.new(:operator => operator, :lhs => expr, :rhs => rhs)
          end
          return expr
        end
      end
    end
    
    class List < self
      attr_accessor :items

      def to_sql
        "(#{items.map {|i| i.to_sql}.join(', ')})"
      end

      def self.parse(tokens)
        tokens.consume(SQLTree::Token::LPAREN)
        items = [SQLTree::Node::Expression.parse(tokens)]
        while SQLTree::Token::COMMA === tokens.peek
          tokens.consume(SQLTree::Token::COMMA)
          items << SQLTree::Node::Expression.parse(tokens)
        end
        tokens.consume(SQLTree::Token::RPAREN)

        self.new(:items => items)
      end
    end
    
    class Function < Expression
      attr_accessor :function, :arguments

      def to_sql
        "#{@function}(" + @arguments.map { |e| e.to_sql }.join(', ') + ")"
      end

      def self.parse(tokens)
        fcall = self.new(:function => tokens.next.literal, :arguments => [])
        tokens.consume(SQLTree::Token::LPAREN)
        
        # See if there are any arguments given.
        unless SQLTree::Token::RPAREN === tokens.peek
          # Parse arguments one by one.
          fcall.arguments << SQLTree::Node::Expression.parse(tokens)
          while SQLTree::Token::COMMA === tokens.peek
            tokens.consume(SQLTree::Token::COMMA)
            fcall.arguments << SQLTree::Node::Expression.parse(tokens)
          end
        end
        tokens.consume(SQLTree::Token::RPAREN)
        return fcall
      end
    end    
  end
end
