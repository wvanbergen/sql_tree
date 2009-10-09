module SQLTree::Node

  class Ordering < Base

    attr_accessor :expression, :direction

    def initialize(expression, direction = nil)
      @expression, @direction = expression, direction
    end

    def to_sql
      sql = expression.to_sql
      sql << " #{direction.to_s.upcase}" if direction
      sql
    end

    def self.parse(tokens)
      ordering = self.new(SQLTree::Node::Expression.parse(tokens))
      if tokens.peek && tokens.peek.direction?
        ordering.direction = tokens.next.literal.downcase.to_sym
      end
      return ordering
    end
  end
end