module SQLTree::Node
  class BeginStatement < Base
    def to_sql(options = {})
      "BEGIN"
    end

    def self.parse(tokens)
      tokens.consume(SQLTree::Token::BEGIN)
      return self.new
    end
  end
end
