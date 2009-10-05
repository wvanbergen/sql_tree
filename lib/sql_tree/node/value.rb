module SQLTree::Node
  
  class Value < Base
    attr_accessor :value

    def initialize(value)
      @value = value
    end
  
    def to_sql
      @value.kind_of?(String) ? quote_str(@value) : @value.to_s
    end
    
    def to_tree
      @value
    end
    
    def ==(other)
      other.value == self.value
    end
    
    def self.parse(tokens)
      case tokens.next
      when SQLTree::Token::String, SQLTree::Token::Number
        SQLTree::Node::Value.new(tokens.current.literal)
      else
        raise SQLTree::Parser::UnexpectedToken.new(tokens.current, :literal)
      end      
    end
  end
end
