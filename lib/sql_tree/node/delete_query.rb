module SQLTree::Node

  # The <tt>DeleteQuery</tt> node represents an SQL DELETE query.
  #
  # This node has two children: <tt>table</tt> and <tt>where</tt>.
  class DeleteQuery < Base

    # The table (<tt>SQLTree::Node::TableReference</tt>) from which to delete records.
    child :table
    
    # The <tt>SQLTree::Node::Expression</tt> instance that defines what
    # nodes to delete.
    child :where

    # Initializes a new DeleteQuery instance.
    def initialize(table, where = nil)
      @table, @where = table, where
    end

    # Generates an SQL DELETE query from this node.
    def to_sql(options = {})
      sql = "DELETE FROM #{table.to_sql(options)}"
      sql << " WHERE #{where.to_sql(options)}" if self.where
      sql
    end
    
    # Parses a DELETE query from a stream of tokens.
    # <tt>tokens</tt>:: The token stream to parse from, which is an instance
    #                   of <tt> SQLTree::Parser</tt>.
    def self.parse(tokens)
      tokens.consume(SQLTree::Token::DELETE)
      tokens.consume(SQLTree::Token::FROM)
      delete_query = self.new(SQLTree::Node::TableReference.parse(tokens))
      if SQLTree::Token::WHERE === tokens.peek
        tokens.consume(SQLTree::Token::WHERE)
        delete_query.where = SQLTree::Node::Expression.parse(tokens)
      end
      return delete_query
    end
  end
end
