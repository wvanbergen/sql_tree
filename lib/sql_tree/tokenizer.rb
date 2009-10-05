class SQLTree::Tokenizer
  
  include Enumerable
  
  def tokenize(string)
    @string = string
    @current_char_pos = -1    
    to_a
  end
  
  def current_char
    @current_char
  end

  def peek_char(amount = 1)
    @string[@current_char_pos + amount, 1]
  end

  def next_char
    @current_char_pos += 1
    @current_char = @string[@current_char_pos, 1]
  end

  OPERATOR_CHARS = /\=|<|>|!|\-|\+|\/|\*|\%/

  def each_token(&block)
    while next_char
      case current_char
      when /^\s?$/;        # whitespace, go to next token
      when '(';            yield(SQLTree::Token::LPAREN)
      when ')';            yield(SQLTree::Token::RPAREN)
      when '.';            yield(SQLTree::Token::DOT)
      when ',';            yield(SQLTree::Token::COMMA)
      when /\d/;           tokenize_number(&block)
      when "'";            tokenize_quoted_string(&block)
      when OPERATOR_CHARS; tokenize_operator(&block)
      when /\w/;           tokenize_literal(&block)
      when '"';            tokenize_quoted_literal(&block)     # TODO: allow MySQL quoting mode   
      end      
    end
  end
  
  alias :each :each_token
  
  def tokenize_literal(&block)
    literal = current_char
    literal << next_char while /[\w]/ =~ peek_char
      
    if SQLTree::Token::KEYWORDS.include?(literal.downcase)
      yield(SQLTree::Token.const_get(literal.upcase))
    else
      yield(SQLTree::Token::Variable.new(literal))
    end
  end

  def tokenize_number(&block)
    number = current_char
    dot_encountered = false
    while /\d/ =~ peek_char || (peek_char == '.' && !dot_encountered)
      dot_encountered = true if peek_char == '.'
      number << next_char
    end
    
    if dot_encountered
      yield(SQLTree::Token::Number.new(number.to_f))
    else
      yield(SQLTree::Token::Number.new(number.to_i))
    end
  end

  def tokenize_quoted_string(&block)
    string = ''
    until next_char.nil? || current_char == "'"
      string << (current_char == "\\" ? next_char : current_char)
    end
    yield(SQLTree::Token::String.new(string))
  end
  
  def tokenize_quoted_literal(&block)
    literal = ''
    until next_char.nil? || current_char == '"' # TODO: allow MySQL quoting mode
      literal << (current_char == "\\" ? next_char : current_char)
    end
    yield(SQLTree::Token::Variable.new(literal))     
  end
  
  
  def tokenize_operator(&block)
    operator = current_char
    if operator == '-' && /[\d\.]/ =~ peek_char 
      tokenize_number(&block)
    else
      operator << next_char if SQLTree::Token::OPERATORS.has_key?(operator + peek_char)
      yield(SQLTree::Token.const_get(SQLTree::Token::OPERATORS[operator].to_s.upcase))
    end
  end
  
  
end
