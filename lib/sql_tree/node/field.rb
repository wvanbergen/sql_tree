module SQLTree::Node
  
  class Field < Base

    attr_accessor :name, :table

    alias :field :name
    alias :field= :name=

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
    
    def ==(other)
      other.name == self.name && other.table == self.table
    end
    
    def self.parse(tokens)
      field_or_table = case tokens.next
        when SQLTree::Token::MULTIPLY then :all
        when SQLTree::Token::Variable then tokens.current.literal
        else raise SQLTree::Parser::UnexpectedToken.new(tokens.current)
      end

      if tokens.peek == SQLTree::Token::DOT
        table = field_or_table
        tokens.consume(SQLTree::Token::DOT)
        field = case tokens.next
          when SQLTree::Token::MULTIPLY then :all
          when SQLTree::Token::Variable then tokens.current.literal
          else raise SQLTree::Parser::UnexpectedToken.new(tokens.current)
        end
        self.new(field, table)
      else
        self.new(field_or_table)
      end
    end
  end
end
