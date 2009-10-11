module SQLTree::Node

  # The Assignment node is used to represent the assignment of a new
  # value to a field in an UPDATE query.
  #
  # This node has two children: <tt>field</tt> and <tt>expression</tt>.
  class Assignment < Base
    
    # The field (<tt>String</tt>) to update 
    attr_accessor :field
    
    # A <tt>SQLTree::Node::Expression</tt> instance that is used to 
    # update the field with.
    attr_accessor :expression
    
    # Initializes a new assignment node.
    def initialize(field, expression = nil)
      @field, @expression = field, expression
    end
    
    # Generates an SQL fragment for this node.
    def to_sql
      "#{quote_var(field)} = #{expression.to_sql}"
    end
    
    # Parses an Assignment node from a stream of tokens
    # <tt>tokens</tt>:: The token stream to parse from, which is an instance
    #                   of <tt>SQLTree::Parser</tt>.
    def self.parse(tokens)
      assignment = self.new(SQLTree::Node::Variable.parse(tokens).name)
      tokens.consume(SQLTree::Token::EQ)
      assignment.expression = SQLTree::Node::Expression.parse(tokens)
      assignment
    end
  end
end
