module SQLTree::Node
  class AllFieldsExpression < Expression
    def to_sql
      '*'
    end
  end
end
