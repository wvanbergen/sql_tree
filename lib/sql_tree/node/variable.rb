module SQLTree::Node
  
  class Variable < Base

    attr_accessor :name

    def initialize(name)
      @name = name
    end
  
    def to_sql
      quote_var(@name)
    end
    
    def to_tree
      @name.to_sym
    end
    
    def ==(other)
      other.name == self.name
    end

    def self.parse(parser)
      if SQLTree::Token::Variable === parser.peek_token
        if parser.peek_token(2) == SQLTree::Token::DOT
          SQLTree::Node::Field.parse(parser)
        else
          self.new(parser.next_token.literal)
        end
      else
        raise SQLTree::Parser::UnexpectedToken.new(parser.peek_token, :variable)
      end
    end
  end
end
