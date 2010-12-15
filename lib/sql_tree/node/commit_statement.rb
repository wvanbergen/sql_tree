module SQLTree::Node
  class CommitStatement < Base
    def to_sql(options = {})
      "COMMIT"
    end

    def self.parse(tokens)
      tokens.consume(SQLTree::Token::COMMIT)
      return self.new
    end
  end
end
