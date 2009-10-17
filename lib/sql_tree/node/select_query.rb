module SQLTree::Node

  class SelectQuery < Base

    leaf :distinct
    child :select
    child :from
    child :where
    child :group_by
    child :having
    child :order_by
    child :limit

    def initialize
      @distinct = false
      @select   = []
    end

    def to_sql(options = {})
      raise "At least one SELECT expression is required" if self.select.empty?
      sql = (self.distinct) ? "SELECT DISTINCT " : "SELECT "
      sql << select.map { |s| s.to_sql(options) }.join(', ')
      sql << " FROM "     << from.map { |f| f.to_sql(options) }.join(', ') if from
      sql << " WHERE "    << where.to_sql(options) if where
      sql << " GROUP BY " << group_by.map { |g| g.to_sql(options) }.join(', ') if group_by
      sql << " ORDER BY " << order_by.map { |o| o.to_sql(options) }.join(', ') if order_by
      sql << " HAVING "   << having.to_sql(options) if having
      return sql
    end

    # Uses the provided initialized parser to parse a SELECT query.
    def self.parse(tokens)
      select_node = self.new
      tokens.consume(SQLTree::Token::SELECT)

      if SQLTree::Token::DISTINCT === tokens.peek
        tokens.consume(SQLTree::Token::DISTINCT)
        select_node.distinct = true
      end

      select_node.select   = parse_list(tokens, SQLTree::Node::SelectDeclaration)
      select_node.from     = self.parse_from_clause(tokens)   if SQLTree::Token::FROM === tokens.peek
      select_node.where    = self.parse_where_clause(tokens)  if SQLTree::Token::WHERE === tokens.peek
      if SQLTree::Token::GROUP === tokens.peek
        select_node.group_by = self.parse_group_clause(tokens)
        select_node.having   = self.parse_having_clause(tokens) if SQLTree::Token::HAVING === tokens.peek
      end
      select_node.order_by = self.parse_order_clause(tokens) if SQLTree::Token::ORDER === tokens.peek
      return select_node
    end

    def self.parse_from_clause(tokens)
      tokens.consume(SQLTree::Token::FROM)
      parse_list(tokens, SQLTree::Node::Source)
    end

    def self.parse_where_clause(tokens)
      tokens.consume(SQLTree::Token::WHERE)
      Expression.parse(tokens)
    end

    def self.parse_group_clause(tokens)
      tokens.consume(SQLTree::Token::GROUP, SQLTree::Token::BY)
      parse_list(tokens)
    end

    def self.parse_having_clause(tokens)
      tokens.consume(SQLTree::Token::HAVING)
      SQLTree::Node::Expression.parse(tokens)
    end

    def self.parse_order_clause(tokens)
      tokens.consume(SQLTree::Token::ORDER, SQLTree::Token::BY)
      parse_list(tokens, SQLTree::Node::Ordering)
    end

    def self.parse_limit_clause(tokens)
      # TODO: implement me
    end
  end
end
