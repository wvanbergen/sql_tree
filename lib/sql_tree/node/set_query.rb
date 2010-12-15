module SQLTree::Node

  # The <tt>DeleteQuery</tt> node represents an SQL DELETE query.
  #
  # This node has two children: <tt>table</tt> and <tt>where</tt>.
  class SetQuery < Base

    # The variable (<tt>SQLTree::Node::Field</tt>) that is being set.
    child :variable
    
    # The <tt>SQLTree::Node::Expression</tt> value that the variable is being
    # set to.
    child :value

    # Initializes a new DeleteQuery instance.
    def initialize(variable, value)
      @variable, @value = variable, value
    end

    # Generates an SQL DELETE query from this node.
    def to_sql(options = {})
      sql = "SET #{variable.to_sql(options)}"
      sql << " TO #{value.to_sql(options)}"
      sql
    end
    
    # Parses a SET query from a stream of tokens.
    # <tt>tokens</tt>:: The token stream to parse from, which is an instance
    #                   of <tt> SQLTree::Parser</tt>.
    def self.parse(tokens)
      tokens.consume(SQLTree::Token::SET)
      variable = SQLTree::Node::Expression::Field.parse(tokens)
      tokens.consume(SQLTree::Token::TO)
      value = SQLTree::Node::Expression::Value.parse(tokens)
      return self.new(variable, value)
    end
  end
end
