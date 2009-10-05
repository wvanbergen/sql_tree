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
    
    def self.parse(parser)
      case parser.next_token
      when SQLTree::Token::String, SQLTree::Token::Number
        SQLTree::Node::Value.new(parser.current_token.literal)
      else
        raise SQLTree::Parser::UnexpectedToken.new(parser.current_token, :literal)
      end      
    end
  end
end
