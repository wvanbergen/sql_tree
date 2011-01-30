module SQLTree::Node
  class RollbackStatement < Base
    def to_sql(options = {})
      "ROLLBACK"
    end

    def self.parse(tokens)
      tokens.consume(SQLTree::Token::ROLLBACK)
      return self.new
    end
  end
end
