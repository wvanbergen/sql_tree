module SQLTree::Node
  
  class Field < Base

    attr_accessor :name, :table

    def initialize(name, table = nil)
      @name = name
      @table = table
    end

    def quote_var(name)
      return '*' if name == :all
      super(name)
    end

    def to_sql
      @table.nil? ? quote_var(@name) : quote_var(@table) + '.' + quote_var(@name)
    end

    def to_tree
      to_sql.to_sym
    end
    
    def ==(other)
      other.name == self.name && other.table == self.table
    end
    
    def self.parse(tokens)
      lhs = tokens.next
      lhs = (lhs == SQLTree::Token::MULTIPLY) ? :all : lhs.literal

      if tokens.peek == SQLTree::Token::DOT
        tokens.consume(SQLTree::Token::DOT)
        rhs = tokens.next
        rhs = (rhs == SQLTree::Token::MULTIPLY) ? :all : rhs.literal      
        self.new(rhs, lhs)
      else
        self.new(lhs)
      end
    end
  end
end
