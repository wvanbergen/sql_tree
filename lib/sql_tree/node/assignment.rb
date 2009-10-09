module SQLTree::Node

  class Assignment < Base
    
    attr_accessor :field, :expression
    
    def initialize(field, expression = nil)
      @field, @expression = field, expression
    end
    
    def to_sql
      "#{quote_var(field)} = #{expression.to_sql}"
    end
    
    def self.parse(tokens)
      assignment = self.new(SQLTree::Node::Variable.parse(tokens).name)
      tokens.consume(SQLTree::Token::EQ)
      assignment.expression = SQLTree::Node::Expression.parse(tokens)
      assignment
    end
  end
end
