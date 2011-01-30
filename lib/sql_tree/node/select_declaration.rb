module SQLTree::Node

  class SelectExpression < Base
    
    def self.parse(tokens)
      case tokens.peek
      when SQLTree::Token::COUNT
        SQLTree::Node::CountAggregrate.parse(tokens)
      else
        SQLTree::Node::Expression.parse(tokens)
      end
    end
  end

  class SelectDeclaration < Base

    child :expression
    leaf :variable

    def to_sql(options = {})
      sql = @expression.to_sql(options)
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
        
        expr = self.new(:expression => SQLTree::Node::SelectExpression.parse(tokens))
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
  end
  
  class CountAggregrate < Base
    leaf :distinct
    child :expression
  
    def to_sql(options = {})
      sql = "COUNT("
      sql << "DISTINCT " if distinct
      sql << expression.to_sql(options)
      sql << ')'
    end
  
    def self.parse(tokens)
      count_aggregate = self.new(:distinct => false)
      
      tokens.consume(SQLTree::Token::COUNT)
      tokens.consume(SQLTree::Token::LPAREN)
      
      # Handle DISTINCT
      distinct_parens = false
      if SQLTree::Token::DISTINCT === tokens.peek
        tokens.consume(SQLTree::Token::DISTINCT)
        count_aggregate.distinct = true
        if SQLTree::Token::LPAREN === tokens.peek
          tokens.consume(SQLTree::Token::LPAREN)
          distinct_parens = true
        end
      end
      
      if SQLTree::Token::MULTIPLY === tokens.peek
        
        # "COUNT(*)"
        tokens.consume(SQLTree::Token::MULTIPLY)
        count_aggregate.expression = SQLTree::Node::ALL_FIELDS
        
      elsif SQLTree::Token::Identifier === tokens.peek(1) &&
            SQLTree::Token::DOT        === tokens.peek(2) &&
            SQLTree::Token::MULTIPLY   === tokens.peek(3)
            
        # "COUNT(table.*)"
        table = tokens.next.literal
        tokens.consume(SQLTree::Token::DOT, SQLTree::Token::MULTIPLY)
        count_aggregate.expression =  SQLTree::Node::AllFieldsDeclaration.new(table)

      else
      
        count_aggregate.expression = SQLTree::Node::Expression.parse(tokens)
      end
      
      tokens.consume(SQLTree::Token::RPAREN) if distinct_parens
      tokens.consume(SQLTree::Token::RPAREN)
    
      return count_aggregate
    end
  end

  class AllFieldsDeclaration < Base
    
    leaf :table
    
    def initialize(table = nil)
      @table = table
    end
    
    def to_sql(options = {})
      table ? "#{quote_var(table)}.*" : '*'
    end
  end

  ALL_FIELDS = AllFieldsDeclaration.new
end
