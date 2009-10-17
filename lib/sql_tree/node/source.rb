module SQLTree::Node

  class Source < Base

    child :table_reference
    child :joins

    def initialize(table_reference, joins = [])
      @table_reference, @joins = table_reference, joins
    end

    def table
      table_reference.table
    end

    def table_alias
      table_reference.table_alias
    end

    def to_sql(options = {})
      sql = table_reference.to_sql(options)
      sql << ' ' << joins.map { |j| j.to_sql(options) }.join(' ') if joins.any?
      return sql
    end

    def self.parse(tokens)
      source = self.new(SQLTree::Node::TableReference.parse(tokens))
      while tokens.peek && tokens.peek.join?
        source.joins << SQLTree::Node::Join.parse(tokens)
      end
      return source
    end
  end
end
