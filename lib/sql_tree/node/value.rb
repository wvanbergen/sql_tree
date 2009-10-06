module SQLTree::Node
  
  class Value < Base
    attr_accessor :value

    def initialize(value)
      @value = value
    end
  
    def to_sql
      case value
      when nil    then 'NULL'
      when String then quote_str(@value)
      else             @value.to_s
      end
    end
    
    def to_tree
      @value
    end
    
    def ==(other)
      other.kind_of?(self.class) && other.value == self.value
    end
    
    def self.parse(tokens)
      case tokens.next
      when SQLTree::Token::String, SQLTree::Token::Number
        SQLTree::Node::Value.new(tokens.current.literal)
      when SQLTree::Token::NULL
        SQLTree::Node::Value.new(nil)
      else
        raise SQLTree::Parser::UnexpectedToken.new(tokens.current, :literal)
      end      
    end
  end
end
