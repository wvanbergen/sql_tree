class SQLTree::Parser

  class UnexpectedToken < StandardError
    
    attr_reader :expected_token, :actual_token
    
    def initialize(expected_token, actual_token)
      @expected_token, @actual_token = expected_token, actual_token
      super("Unexpected token: #{expected_token.inspect} expected, but found #{actual_token.inspect}.")
    end
  end

  def self.parse(sql_string, options = {:as => :query})
    self.new.parse(sql_string, options)
  end

  def current_token
    @current_token
  end
  
  def next_token
    @current_token = @tokens.shift
  end
  
  def consume(check)
    raise UnexpectedToken.new(check, current_token) unless check == next_token
  end
  
  def peek_token(distance = 1)
    @tokens[distance - 1]
  end
  
  def error(token, check)
    raise ParseError.new("Unexpected token: #{token.inspect} found, but #{check.inspect} expected.")
  end
  
  def debug
    p @tokens.inspect
  end
  
  def parse(tokens, options = {:as => :query})
    if tokens.kind_of?(String)
      tokenizer = SQLTree::Tokenizer.new
      @tokens   = tokenizer.tokenize(tokens)
    else
      @tokens   = tokens
    end
    
    send("parse_#{options[:as]}".to_sym)
  end
  
  def parse_query
    case peek_token
    when SQLTree::Token::SELECT; parse_select_query
    else raise "Could not parse query"
    end
  end
  
  def parse_select_query
    select_node = SQLTree::Node::SelectQuery.new
    consume(SQLTree::Token::SELECT)
    
    if peek_token == SQLTree::Token::DISTINCT
      consume(SQLTree::Token::DISTINCT)
      select_node.distinct = true
    end
    
    select_node.select = parse_select_clause 
    select_node.from   = parse_from_clause   if peek_token == SQLTree::Token::FROM
    select_node.where  = parse_where_clause  if peek_token == SQLTree::Token::WHERE
    
    return select_node
  end
  
  def parse_select_clause
    expressions = [parse_select_expression]
    while peek_token == SQLTree::Token::COMMA
      consume(SQLTree::Token::COMMA)
      expressions << parse_select_expression
    end
    return expressions
  end
  
  def parse_select_expression
    if peek_token == SQLTree::Token::MULTIPLY
      consume(SQLTree::Token::MULTIPLY)
      return SQLTree::Node::ALL_FIELDS 
    else
      expr = SQLTree::Node::SelectExpression.new(parse_expression)
      if peek_token == SQLTree::Token::AS
        consume(SQLTree::Token::AS)
        expr.variable = parse_variable_name.name
      end
      return expr
    end
  end
  
  def parse_single_expression
    if SQLTree::Token::LPAREN === peek_token(1)
      consume(SQLTree::Token::LPAREN)
      expr = parse_expression
      consume(SQLTree::Token::RPAREN)
      return expr
    elsif SQLTree::Token::Variable === peek_token(1)  && peek_token(2) == SQLTree::Token::LPAREN
      return parse_function_call
    elsif SQLTree::Token::Variable === peek_token(1)
      return parse_variable
    else
      return parse_value
    end    
  end
  
  def parse_expression
    parse_logical_expression
  end

  def parse_secondary_arithmetic_expression
    expr = parse_single_expression
    while [SQLTree::Token::PLUS, SQLTree::Token::MINUS].include?(peek_token)
      expr = SQLTree::Node::ArithmeticExpression.new(next_token.literal, expr, parse_single_expression)
    end
    return expr    
  end

  
  def parse_primary_arithmetic_expression
    expr = parse_secondary_arithmetic_expression
    while [SQLTree::Token::PLUS, SQLTree::Token::MINUS].include?(peek_token)
      expr = SQLTree::Node::ArithmeticExpression.new(next_token.literal, expr, parse_secondary_arithmetic_expression)
    end
    return expr    
  end
  
  def parse_comparison_expression
    expr = parse_primary_arithmetic_expression    
    while [SQLTree::Token::EQ, SQLTree::Token::NE, SQLTree::Token::GT, SQLTree::Token::GTE, SQLTree::Token::LT, SQLTree::Token::LTE].include?(peek_token)
      expr = SQLTree::Node::ComparisonExpression.new(next_token.literal, expr, parse_primary_arithmetic_expression)   
    end
    return expr
  end
  
  def parse_logical_expression
    expr = parse_comparison_expression
    while [SQLTree::Token::AND, SQLTree::Token::OR].include?(peek_token)
      expr = SQLTree::Node::LogicalExpression.new(next_token.literal, [expr, parse_comparison_expression])   
    end 
    return expr
  end
  
  def parse_logical_not_expression  
    
  end
  
  def parse_function_call
    
    expr = SQLTree::Node::FunctionExpression.new(next_token.literal)
    consume(SQLTree::Token::LPAREN)
    until peek_token == SQLTree::Token::RPAREN
      expr.arguments << parse_expression
      consume(SQLTree::Token::COMMA) if peek_token == SQLTree::Token::COMMA
    end
    consume(SQLTree::Token::RPAREN)
    return expr
  end
  
  def parse_from_clause
    consume(SQLTree::Token::FROM)
    from_expressions = [parse_from_expression]
    while peek_token == SQLTree::Token::COMMA
      consume(SQLTree::Token::COMMA)
      from_expressions << parse_from_expression
    end 

    return from_expressions    
  end
  
  def parse_from_expression
    from_expression = case peek_token
      when SQLTree::Token::Variable;  parse_table_import
      else;                           error(peek_token)
    end
    return from_expression
  end
  
  def parse_table_import
    table_import = SQLTree::Node::TableImport.new(next_token.literal)
    if peek_token == SQLTree::Token::AS || SQLTree::Token::Variable === peek_token
      consume(SQLTree::Token::AS) if peek_token == SQLTree::Token::AS
      table_import.variable = parse_variable_name.name
    end
    return table_import
  end
  
  def parse_field
    lhs = next_token
    lhs = (lhs == SQLTree::Token::MULTIPLY) ? :all : lhs.literal
    
    if peek_token == SQLTree::Token::DOT
      consume(SQLTree::Token::DOT)
      rhs = next_token
      rhs = (rhs == SQLTree::Token::MULTIPLY) ? :all : rhs.literal      
      SQLTree::Node::Field.new(rhs, lhs)
    else
      SQLTree::Node::Field.new(lhs)
    end
  end
  
  def parse_variable_name
    return SQLTree::Node::Variable.new(next_token.literal)
  end

  def parse_variable
    if peek_token(2) == SQLTree::Token::DOT
      parse_field
    else
      parse_variable_name
    end
  end
  
  def parse_value
    SQLTree::Node::Value.new(next_token.literal)
  end

    
  def parse_where_clause
    consume(SQLTree::Token::WHERE)
    return parse_expression
  end
  
end
