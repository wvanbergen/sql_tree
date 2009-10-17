module SQLTree::Node

  # The UpdateQuery class represents an SQL +UPDATE+ query.
  #
  # This root node has three children: +table+, +updates+ and +where+.
  class UpdateQuery < Base
    
    # The table ({SQLTree::Node::TableReference}) to update.
    attr_accessor :table
    
    # The updates to do in the table. This is an array of 
    # {SQLTree::Node::UpdateQuery::Assignment} instances.
    attr_accessor :updates
    
    # The {SQLTree::Node::Expression} instance that restricts the records that
    # should be updated.
    attr_accessor :where
    
    def initialize(table, updates = [], where = nil)
      @table, @updates, @where = table, updates, where
    end
    
    # Generates the SQL UPDATE query.
    # @return [String] The SQL update query
    def to_sql(options = {})
      sql = "UPDATE #{table.to_sql(options)} SET "
      sql << updates.map { |u| u.to_sql(options) }.join(', ')
      sql << " WHERE " << where.to_sql(options) if self.where
      sql
    end
    
    # Parses an SQL UPDATE query. Syntax:
    #
    #   UpdateQuery -> UPDATE TableReference 
    #                     SET Assignment (COMMA Assignment)*
    #                     (WHERE Expression)?
    #
    # @param [SQLTree::Parser] tokens The token stream to parse from.
    # @return [SQLTree::Node::UpdateQuery] The parsed UpdateQuery instance.
    # @raise [SQLTree::Parser::UnexpectedToken] if an unexpected token is
    #    encountered during parsing.
    def self.parse(tokens)
      tokens.consume(SQLTree::Token::UPDATE)
      update_query = self.new(SQLTree::Node::TableReference.parse(tokens))
      tokens.consume(SQLTree::Token::SET)
      update_query.updates = [SQLTree::Node::UpdateQuery::Assignment.parse(tokens)]
      while SQLTree::Token::COMMA === tokens.peek
        tokens.consume(SQLTree::Token::COMMA)
        update_query.updates << SQLTree::Node::UpdateQuery::Assignment.parse(tokens)
      end
      
      if SQLTree::Token::WHERE === tokens.peek
        tokens.consume(SQLTree::Token::WHERE)
        update_query.where = SQLTree::Node::Expression.parse(tokens)
      end
      
      update_query
    end

    # The Assignment node is used to represent the assignment of a new
    # value to a field in an +UPDATE+ query.
    #
    # This node has two children: <tt>field</tt> and <tt>expression</tt>.
    class Assignment < Base
    
      # The field ({SQLTree::Node::Expression::Field}) to update.
      attr_accessor :field
    
      # A {SQLTree::Node::Expression} instance that is used to 
      # update the field with.
      attr_accessor :expression
    
      # Initializes a new assignment node.
      def initialize(field, expression = nil)
        @field, @expression = field, expression
      end
    
      # Generates an SQL fragment for this node.
      # @return [String] An SQL fragment that can be embedded in the SET
      #    clause of on SQL UPDATE query.
      def to_sql(options = {})
        "#{field.to_sql(options)} = #{expression.to_sql(options)}"
      end
    
      # Parses an Assignment node from a stream of tokens. Syntax:
      #
      #   Assignment -> <identifier> EQ Expression
      #
      # @param [SQLTree::Parser] tokens The token stream to parse from.
      # @return [SQLTree::Node::Assignment] The parsed assignment instance.
      # @raise [SQLTree::Parser::UnexpectedToken] if an unexpected token is
      #    encountered during parsing.
      def self.parse(tokens)
        assignment = self.new(SQLTree::Node::Expression::Field.parse(tokens))
        tokens.consume(SQLTree::Token::EQ)
        assignment.expression = SQLTree::Node::Expression.parse(tokens)
        assignment
      end
    end
  end
end
