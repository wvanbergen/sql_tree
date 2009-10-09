module SQLTree::Node
  
  class Variable < Base

    attr_accessor :name

    def initialize(name)
      @name = name
    end
  
    def to_sql
      quote_var(@name)
    end
    
    def ==(other)
      other.name == self.name
    end

    def self.parse(tokens)
      if SQLTree::Token::Variable === tokens.peek
        if tokens.peek(2) == SQLTree::Token::DOT
          SQLTree::Node::Field.parse(tokens)
        else
          self.new(tokens.next.literal)
        end
      else
        raise SQLTree::Parser::UnexpectedToken.new(tokens.peek, :variable)
      end
    end
  end
end
