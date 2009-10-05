module SQLTree::Node
  
  ALL_FIELDS = AllFieldsExpression.new
  
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
    
    def self.parse(parser)
      if parser.peek_token == SQLTree::Token::MULTIPLY
        parser.consume(SQLTree::Token::MULTIPLY)
        return SQLTree::Node::ALL_FIELDS
      else
        expression = SQLTree::Node::Expression.parse(parser)
        expr = SQLTree::Node::SelectExpression.new(expression)
        if parser.peek_token == SQLTree::Token::AS
          parser.consume(SQLTree::Token::AS)
          expr.variable = SQLTree::Node::Variable.parse(parser).name
        end
        return expr
      end      
    end
    
    def ==(other)
      other.expression == self.expression && other.variable == self.variable
    end    
  end
end
