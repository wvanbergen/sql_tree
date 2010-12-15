module SQLTree::Node

  # Abstract base class for all SQL expressions.
  #
  # To parse a string as an SQL expression, use:
  #
  #   SQLTree::Node::Expression["(3 + 2 = 10 / 2) AND MD5('$ecret') = password"]
  #
  # This is an abtract class: its parse method will never return an
  # <tt>SQLTree::Node::Expression</tt> instance, but always an instance
  # of one of its subclasses. The concrete expression classes are defined in the
  # SQLTree::Node::Expression namespace.
  class Expression < Base

    # Parses an SQL expression from a stream of tokens.
    #
    # This method will start trying to parse the token stream as a 
    # <tt>SQLTree::Node::Expression::BinaryOperator</tt>, which will in turn try 
    # to parse it as other kinds of expressions if a binary expression is not appropriate.
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
          FunctionCall.parse(tokens)
        elsif SQLTree::Token::DOT === tokens.peek(2)
          Field.parse(tokens)
        else
          Variable.parse(tokens)
        end
      elsif SQLTree::Token::STRING_ESCAPE == tokens.peek
        tokens.consume(SQLTree::Token::STRING_ESCAPE)
        Value.parse(tokens)
      elsif SQLTree::Token::INTERVAL === tokens.peek
        IntervalValue.parse(tokens)
      else
        Value.parse(tokens)
      end
    end
    
    # A prefix operator expression parses a construct that consists of an
    # operator and an expression. Currently, the only prefix operator that 
    # is supported is the NOT keyword.
    #
    # This node has two child nodes: <tt>operator</tt> and <tt>rhs</tt>.
    class PrefixOperator  < SQLTree::Node::Expression
      
      # The list of operator tokens that can be used as prefix operator.
      TOKENS = [SQLTree::Token::NOT]
      
      # The SQL operator as <tt>String</tt> that was used for this expression.
      leaf :operator
      
      # The right hand side of the prefix expression, i.e. the <tt>SQLTree::Node::Expression</tt>
      # instance that appeared after the operator.
      child :rhs
      
      # Generates an SQL fragment for this prefix operator expression.
      def to_sql(options = {})
        "#{operator} #{rhs.to_sql(options)}"
      end
      
      # Parses the operator from the token stream.
      # <tt>tokens</tt>:: the token stream to parse from.
      def self.parse_operator(tokens)
        tokens.next.literal.upcase
      end
      
      # Parses a prefix operator expression, by first parsing the operator
      # and then parsing the right hand side expression.
      # <tt>tokens</tt>:: the token stream to parse from, which is an instance
      #                   of <tt> SQLTree::Parser</tt>.
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
    
    # A postfix operator expression is a construct in which the operator appears 
    # after a (left-hand side) expression.
    #
    # This operator has two child nodes: <tt>operator</tt> and <tt>lhs</tt>.
    #
    # Currently, SQLTreedoes not support any postfix operator.
    class PostfixOperator  < SQLTree::Node::Expression
      
      # The left-hand side <tt>SQLTree::Node::Expression</tt> instance that was parsed
      # before the postfix operator.
      child :lhs
      
      # The postfoix operator for this expression as <tt>String</tt>.
      leaf :operator
            
      # Generates an SQL fragment for this postfix operator expression.
      def to_sql(options = {})
        "#{lhs.to_sql(options)} #{operator}"
      end
      
      # Parses a postfix operator expression. This method is not yet implemented.
      # <tt>tokens</tt>:: The token stream to parse from, which is an instance
      #                   of <tt> SQLTree::Parser</tt>.
      def self.parse(tokens)
        raise "Not yet implemented"
      end
    end
    
    # A binary operator expression consists of a left-hand side expression (lhs), the
    # binary operator itself and a right-hand side expression (rhs). It therefore has
    # three children: <tt>operator</tt>, <tt>lhs</tt> and <tt>rhs</tt>.
    #
    # When multiple binary operators appear in an expression, they can be grouped
    # using parenthesis (e.g. "(1 + 3) / 2", or "1 + (3 / 2)" ). If the parentheses
    # are absent, the grouping is determined using the precedence of the operator.
    class BinaryOperator  < SQLTree::Node::Expression
      
      # The token precedence list. Tokens that occur first in this list have
      # the lowest precedence, the last tokens have the highest. This impacts
      # parsing when no parentheses are used to indicate how operators should
      # be grouped.
      #
      # The token precedence list is taken from the SQLite3 documentation:
      # http://www.sqlite.org/lang_expr.html
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
      
      # A list of binary operator tokens, taken from the operator precedence list.
      TOKENS = TOKEN_PRECEDENCE.flatten
      
      # The operator to use for this binary operator expression.
      leaf :operator
      
      # The left hand side <tt>SQLTree::Node::Expression</tt> instance for this operator.
      child :lhs
      
      # The rights hand side <tt>SQLTree::Node::Expression</tt> instance for this operator.
      child :rhs
      
      # Generates an SQL fragment for this exression.
      def to_sql(options = {})
        "(#{lhs.to_sql(options)} #{operator} #{rhs.to_sql(options)})"
      end

      # Parses the operator for this expression. 
      #  
      # Some operators can be negated using the NOT operator (e.g. <tt>IS NOT</tt>, 
      # <tt>NOT LIKE</tt>). This is handled in this function as well.
      #
      # <tt>tokens</tt>:: The token stream to parse from.
      def self.parse_operator(tokens)
        if tokens.peek.optional_not_suffix? && tokens.peek(2).not?
          return "#{tokens.next.literal.upcase} #{tokens.next.literal.upcase}"
        elsif tokens.peek.not? && tokens.peek(2).optional_not_prefix?
          return "#{tokens.next.literal.upcase} #{tokens.next.literal.upcase}"
        else
          return tokens.next.literal.upcase
        end
      end

      # Parses the right hand side expression of the operator.
      #
      # Usually, this will parse another BinaryOperator expression with a higher
      # precedence, but for some operators (+IN+ and +IS+), the default behavior 
      # is overriden to implement exceptions.
      #
      # <tt>tokens</tt>:: The token stream to parse from, which is an instance
      #                   of <tt> SQLTree::Parser</tt>.
      # <tt>precedence</tt>:: The current precedence level. By default, this method
      #                       will try to parse a BinaryOperator expression with a 
      #                       one higher precedence level than the current level.
      # <tt>operator</tt>:: The operator that was parsed.
      def self.parse_rhs(tokens, precedence, operator = nil)
        if ['IN', 'NOT IN'].include?(operator)
          return List.parse(tokens)
        elsif ['IS', 'IS NOT'].include?(operator)
          tokens.consume(SQLTree::Token::NULL)
          return SQLTree::Node::Expression::Value.new(nil)
        else
          return parse(tokens, precedence + 1)
        end
      end
      
      # Parses the binary operator by first parsing the left hand side, then the operator
      # itself, and finally the right hand side.
      #
      #   BinaryOperator -> Expression <operator> Expression
      #
      # This method will try to parse the lowest precedence operator first, and gradually
      # try to parse operators with a higher precedence level. The left and right hand side
      # will both be parsed with a higher precedence level. This ensures that the resulting
      # expression is grouped correctly.
      #
      # If no binary operator is found of any precedence level, this method will back on
      # pasring an atomic expression, see {SQLTree::Node::Expression.parse_atomic}.
      #
      # @param [SQLTree::Parser] tokens The token stream to parse from.
      # @param [Integer] precedence The current precedence level. Starts with the lowest 
      #    precedence level (0) by default.
      # @return [SQLTree::Node::Expression] The parsed expression. This may not be 
      #    a binary operator expression, as this method falls back on parsing other
      #    expresison types if no binary operator is found.
      # @raise [SQLTree::Parser::UnexpectedToken] if an unexpected token is
      #    encountered during parsing.      
      def self.parse(tokens, precedence = 0)
        if precedence >= TOKEN_PRECEDENCE.length
          return SQLTree::Node::Expression.parse_atomic(tokens)
        else
          expr = parse(tokens, precedence + 1)
          while TOKEN_PRECEDENCE[precedence].include?(tokens.peek.class) || (tokens.peek && tokens.peek.not?)
            operator = parse_operator(tokens)
            rhs      = parse_rhs(tokens, precedence, operator)
            expr     = self.new(:operator => operator, :lhs => expr, :rhs => rhs)
          end
          return expr
        end
      end
    end
    
    # Parses a comma-separated list of expressions, which is used after the IN operator.
    # The attribute <tt>items</tt> contains the array of child nodes, all instances of
    # {SQLTree::Node::Expression}.
    class List < SQLTree::Node::Expression
      
      # Include the enumerable module to simplify handling the items in this list.
      include Enumerable
      
      # The items that appear in the list, i.e. an array of {SQLTree::Node::Expression}
      # instances.
      child :items

      def initialize(*items)
        if items.length == 1 && items.first.kind_of?(Array)
          @items = items.first
        elsif items.length == 1 && items.first.kind_of?(Hash)
          super(items.first)
        else
          @items
        end
      end

      # Generates an SQL fragment for this list.
      def to_sql(options = {})
        "(#{items.map {|i| i.to_sql(options)}.join(', ')})"
      end

      # Returns true if this list has no items.
      def empty?
        items.empty?
      end
      
      # Makes sure the enumerable module works over the items in the list.
      def each(&block) # :nodoc:
        items.each(&block)
      end

      # Parses a list of expresison by parsing expressions as long as it sees
      # a comma that indicates the presence of a next expression.
      #
      #   List -> LPAREN (Expression (COMMA Expression)*)? RPAREN
      #
      # @param [SQLTree::Parser] tokens The token stream to parse from.
      # @return [SQLTree::Node::Expression::List] The parsed list instance.
      # @raise [SQLTree::Parser::UnexpectedToken] if an unexpected token is
      # encountered during parsing.
      def self.parse(tokens)
        tokens.consume(SQLTree::Token::LPAREN)
        items = []
        unless SQLTree::Token::RPAREN === tokens.peek
          items = self.parse_list(tokens, SQLTree::Node::Expression)
        end
        tokens.consume(SQLTree::Token::RPAREN)
        self.new(items)
      end
    end
    
    # Represents a SQL function call expression. This node has two child nodes:
    # <tt>function</tt> and <tt>argument_list</tt>.
    class FunctionCall  < SQLTree::Node::Expression

      # The name of the function that is called as <tt>String</tt>.
      leaf :function
      
      # The argument list as {SQLTree::Node::Expression::List} instance.
      child :arguments

      # Generates an SQL fragment for this function call.
      def to_sql(options = {})
        "#{function}(" + arguments.map { |e| e.to_sql(options) }.join(', ') + ")"
      end
      
      # Parses an SQL function call.
      #
      #   FunctionCall -> <identifier> List
      #
      # @param [SQLTree::Parser] tokens The token stream to parse from.
      # @return [SQLTree::Node::Expression::FunctionCall] The parsed function call instance.
      # @raise [SQLTree::Parser::UnexpectedToken] if an unexpected token is
      # encountered during parsing.      
      def self.parse(tokens)
        function_call = self.new(:function => tokens.next.literal, :arguments => [])
        tokens.consume(SQLTree::Token::LPAREN)
        function_call.arguments = self.parse_list(tokens) unless SQLTree::Token::RPAREN === tokens.peek
        tokens.consume(SQLTree::Token::RPAREN)
        return function_call
      end
    end


    # Represents a postgresql INTERVAL value. Example: interval '2 days'.
    #
    # The value is the literal text of the interval (e.g. "2 days").
    class IntervalValue < SQLTree::Node::Expression
      # The actual value this node represents.
      leaf :value

      def initialize(value) # :nodoc:
        @value = value
      end

      # Generates an SQL representation for this value.
      def to_sql(options = {})
        "interval " + quote_str(@value)
      end

      def self.parse(tokens)
        tokens.consume(SQLTree::Token::INTERVAL)
        if SQLTree::Token::String === tokens.peek
          self.new(tokens.next.literal)
        else
          raise SQLTree::Parser::UnexpectedToken.new(tokens.current, :literal)
        end
      end
    end


    # Represents alitreal value in an SQL expression. This node is a leaf node
    # and thus has no child nodes.
    #
    # A value can either be:
    # * the SQL <tt>NULL</tt> keyword, which is represented by <tt>nil</tt>.
    # * an SQL string, which is represented by a <tt>String</tt> instance.
    # * an SQL date or time value, which can be represented as a <tt>Date</tt>, 
    #   <tt>Time</tt> or <tt>DateTime</tt> instance.
    # * an integer or decimal value, which is represented by an appropriate 
    #   <tt>Numeric</tt> instance.
    class Value  < SQLTree::Node::Expression

      # The actual value this node represents.
      leaf :value

      def initialize(value) # :nodoc:
        @value = value
      end

      # Generates an SQL representation for this value.
      #
      # This method supports nil, string, numeric, date and time values.
      #
      # @return [String] A correctly quoted value that can be used safely
      # within an SQL query
      def to_sql(options = {})
        case value
        when nil            then 'NULL'
        when String         then quote_str(@value)
        when Numeric        then @value.to_s
        when Date           then @value.strftime("'%Y-%m-%d'")
        when DateTime, Time then @value.strftime("'%Y-%m-%d %H:%M:%S'")
        else raise "Don't know how te represent this value in SQL!"
        end
      end

      # Parses a literal value.
      #
      #   Value -> (NULL | <string> | <number>)
      #
      # @param [SQLTree::Parser] tokens The token stream to parse from.
      # @return [SQLTree::Node::Expression::Value] The parsed value instance.
      # @raise [SQLTree::Parser::UnexpectedToken] if an unexpected token is
      # encountered during parsing.
      def self.parse(tokens)
        case tokens.next
        when SQLTree::Token::String, SQLTree::Token::Number
          SQLTree::Node::Expression::Value.new(tokens.current.literal)
        when SQLTree::Token::NULL
          SQLTree::Node::Expression::Value.new(nil)
        else
          raise SQLTree::Parser::UnexpectedToken.new(tokens.current, :literal)
        end
      end
    end

    # Represents a variable within an SQL expression. This is a leaf node, so it
    # does not have any child nodes. A variale can point to a field of a table or 
    # to another expression that was declared elsewhere.
    class Variable  < SQLTree::Node::Expression
      
      # The name of the variable as <tt>String</tt>.
      leaf :name

      def initialize(name) # :nodoc:
        @name = name
      end

      # Generates a quoted reference to the variable.
      #
      # @return [String] A correctly quoted variable that can be safely 
      # used in SQL queries
      def to_sql(options = {})
        quote_var(@name)
      end

      # Parses an SQL variable.
      #
      #   Variable -> <identifier>
      #
      # @param [SQLTree::Parser] tokens The token stream to parse from.
      # @return [SQLTree::Node::Expression::Variable] The parsed variable instance.
      # @raise [SQLTree::Parser::UnexpectedToken] if an unexpected token is
      # encountered during parsing.
      def self.parse(tokens)
        if SQLTree::Token::Identifier === tokens.peek
          self.new(tokens.next.literal)
        else
          raise SQLTree::Parser::UnexpectedToken.new(tokens.peek, :variable)
        end
      end
    end
    
    # Represents a reference to a field of a table in an SQL expression.
    # This is a leaf node, which means that it does not have any child nodes.
    class Field < Variable

      # The table in which the field resides. This can be +nil+, in which case
      # the table the field belongs to is inferred from the rest of the query.
      leaf :table
      
      # The name of the field.
      leaf :name

      alias :field :name
      alias :field= :name=

      # Initializes a new Field
      def initialize(name, table = nil)
        @name = name
        @table = table
      end

      # Generates a correctly quoted reference to the field, which can
      # be incorporated safely into an SQL query.
      def to_sql(options = {})
        @table.nil? ? quote_var(@name) : quote_var(@table) + '.' + quote_var(@name)
      end

      # Parses a field, either with or without the table reference.
      #
      #   Field -> (<identifier> DOT)? <identifier>
      #
      # @param [SQLTree::Parser] tokens The token stream to parse from.
      # @return [SQLTree::Node::Expression::Field] The parsed field instance.
      # @raise [SQLTree::Parser::UnexpectedToken] if an unexpected token is
      # encountered during parsing.
      def self.parse(tokens)
        if SQLTree::Token::Identifier === tokens.peek
          field_or_table = tokens.next.literal
        else
          raise SQLTree::Parser::UnexpectedToken.new(tokens.next)
        end

        if SQLTree::Token::DOT === tokens.peek
          tokens.consume(SQLTree::Token::DOT)
          if SQLTree::Token::Identifier === tokens.peek
            self.new(tokens.next.literal, field_or_table)
          else
            raise SQLTree::Parser::UnexpectedToken.new(tokens.next)
          end
        else
          self.new(field_or_table)
        end
      end
    end
  end
end
