require "#{File.dirname(__FILE__)}/../spec_helper"

describe SQLTree::Node::Expression do

  describe '.parse' do
    it "shoud parse a value correctly" do
      SQLTree::Node::Expression['123'].should == SQLTree::Node::Value.new(123)
    end

    it "shoud parse a function call without arguments correctly" do
      function = SQLTree::Node::Expression['NOW()']
      function.function.should == 'NOW'
      function.arguments.should be_empty
    end

    it "shoud parse a function call with arguments correctly" do
      function = SQLTree::Node::Expression["MD5('string')"]
      function.function.should == 'MD5'
      function.arguments.should == [SQLTree::Node::Value.new('string')]
    end

    it "should parse a logical OR expression correctly" do
      logical = SQLTree::Node::Expression["'this' OR 'that"]
      logical.operator.should    == :or
      logical.expressions.should == [SQLTree::Node::Value.new('this'), SQLTree::Node::Value.new('that')]
    end

    it "should parse a logical AND expression correctly" do
      logical = SQLTree::Node::Expression['1 AND 2']
      logical.operator.should    == :and
      logical.expressions        == [SQLTree::Node::Value.new(1), SQLTree::Node::Value.new(2)]
    end

    it "should nest a logical AND expression correctly" do
      logical = SQLTree::Node::Expression['1 AND 2 AND 3']
      logical.should == SQLTree::Node::Expression['(1 AND 2) AND 3']
    end

    it "should nest expressions correctly when parentheses are used" do
      logical = SQLTree::Node::Expression['1 AND (2 AND 3)']
      logical.should_not == SQLTree::Node::Expression['(1 AND 2) AND 3']
    end

    it "should parse a NOT expression without parenteheses correctly" do
      SQLTree::Node::Expression['NOT 1'].should == SQLTree::Node::LogicalNotExpression.new(SQLTree::Node::Value.new(1))
    end

    it "should parse a NOT expression without parenteheses correctly" do
      SQLTree::Node::Expression['NOT(1)'].should == SQLTree::Node::LogicalNotExpression.new(SQLTree::Node::Value.new(1))
    end

    it "should parse a comparison expression correctly" do
      comparison = SQLTree::Node::Expression['1 < 2']
      comparison.operator.should == '<'
      comparison.lhs.should      == SQLTree::Node::Value.new(1)
      comparison.rhs.should      == SQLTree::Node::Value.new(2)
    end

    it "should parse an IS NULL expression corectly" do
      comparison = SQLTree::Node::Expression['field IS NULL']
      comparison.operator.should == 'IS'
      comparison.lhs.should == SQLTree::Node::Variable.new('field')
      comparison.rhs.should == SQLTree::Node::Value.new(nil)
    end

    it "should parse an IS NOT NULL expression corectly" do
      comparison = SQLTree::Node::Expression['field IS NOT NULL']
      comparison.operator.should == 'IS NOT'
      comparison.lhs.should == SQLTree::Node::Variable.new('field')
      comparison.rhs.should == SQLTree::Node::Value.new(nil)
    end

    it "should parse a LIKE expression corectly" do
      comparison = SQLTree::Node::Expression["field LIKE '%search%"]
      comparison.operator.should == 'LIKE'
      comparison.lhs.should == SQLTree::Node::Variable.new('field')
      comparison.rhs.should == SQLTree::Node::Value.new('%search%')
    end

    it "should parse a NOT ILIKE expression corectly" do
      comparison = SQLTree::Node::Expression["field NOT ILIKE '%search%"]
      comparison.operator.should == 'NOT ILIKE'
      comparison.lhs.should == SQLTree::Node::Variable.new('field')
      comparison.rhs.should == SQLTree::Node::Value.new('%search%')
    end

    it "should parse an IN expression correctly" do
      comparison = SQLTree::Node::Expression["field IN (1,2,3,4)"]
      comparison.operator.should == 'IN'
      comparison.lhs.should == SQLTree::Node::Variable.new('field')
      comparison.rhs.should be_kind_of(SQLTree::Node::SetExpression)
    end

    it "should parse a NOT IN expression correctly" do
      comparison = SQLTree::Node::Expression["field NOT IN (1>2, 3+6, 99)"]
      comparison.operator.should == 'NOT IN'
      comparison.lhs.should == SQLTree::Node::Variable.new('field')
      comparison.rhs.should be_kind_of(SQLTree::Node::SetExpression)
    end

  end
end
