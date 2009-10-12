module SQLTree::Node

  class SelectDeclaration < Base

    attr_accessor :expression, :variable

    def to_sql
      sql = @expression.to_sql
      sql << " AS " << quote_var(@variable) if @variable
      return sql
    end

    def self.parse(tokens)
      
      if SQLTree::Token::MULTIPLY === tokens.peek
        
        # "SELECT * FROM ..."
        tokens.consume(SQLTree::Token::MULTIPLY)
        return SQLTree::Node::ALL_FIELDS
        
      elsif SQLTree::Token::Identifier === tokens.peek(1) &&
            SQLTree::Token::DOT        === tokens.peek(2) &&
            SQLTree::Token::MULTIPLY   === tokens.peek(3)
            
        # "SELECT table.* FROM ..."
        table = tokens.next.literal
        tokens.consume(SQLTree::Token::DOT, SQLTree::Token::MULTIPLY)
        return SQLTree::Node::AllFieldsDeclaration.new(table)
        
      else
        
        expression = SQLTree::Node::Expression.parse(tokens)
        expr = self.new(:expression => expression)
        if SQLTree::Token::AS === tokens.peek
          tokens.consume(SQLTree::Token::AS)
          if SQLTree::Token::Identifier === tokens.peek
            expr.variable = tokens.next.literal
          else
            raise SQLTree::Parser::UnexpectedToken.new(tokens.peek)
          end
        end
        return expr
      end
    end

    def ==(other)
      other.class == self.class && other.expression == self.expression && other.variable == self.variable
    end
  end

  class AllFieldsDeclaration < Base
    
    attr_reader :table
    
    def initialize(table = nil)
      @table = table
    end
    
    def ==(other)
      other.class == self.class && other.table == self.table
    end
    
    def to_sql
      table ? "#{quote_var(table)}.*" : '*'
    end
  end

  ALL_FIELDS = AllFieldsDeclaration.new
end
