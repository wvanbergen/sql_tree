module SQLTree::Node
  
  class Source < Base
    
    attr_accessor :table_reference, :joins
    
    def initialize(table_reference, joins = [])
      @table_reference, @joins = table_reference, joins
    end
    
    def table
      table_reference.table
    end

    def table_alias
      table_reference.table_alias
    end
  
    def to_sql
      sql = table_reference.to_sql
      sql << ' ' << joins.map { |j| j.to_sql }.join(' ') if joins.any?
      return sql
    end

    def ==(other)
      other.table_reference = self.table_reference && other.joins == self.joins
    end

    def self.parse(tokens)
      source = self.new(SQLTree::Node::TableReference.parse(tokens))
      while tokens.peek && tokens.peek.join?
        source.joins << Join.parse(tokens)
      end
      return source
    end
  end 
end
