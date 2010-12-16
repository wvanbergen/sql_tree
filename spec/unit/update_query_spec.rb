require 'spec_helper'

describe SQLTree::Node::UpdateQuery do

  it "should parse an UPDATE query without WHERE clause correctly" do
    update = SQLTree::Node::UpdateQuery["UPDATE table SET field1 = 1, field2 = 5 - 3"]
    update.table.should == SQLTree::Node::TableReference.new("table")
    update.updates.should have(2).items
    update.updates[0].field.should == SQLTree::Node::Expression::Field.new("field1")
    update.updates[0].expression.should == SQLTree::Node::Expression::Value.new(1)
    update.updates[1].field.should == SQLTree::Node::Expression::Field.new("field2")
    update.updates[1].expression.should be_kind_of(SQLTree::Node::Expression)
    update.where.should be_nil
  end

  it "should parse an UPDATE query with WHERE clause correctly" do
    update = SQLTree::Node::UpdateQuery["UPDATE table SET field = 1 WHERE id = 17"]
    update.table.should == SQLTree::Node::TableReference.new("table")
    update.updates.should have(1).item
    update.where.should be_kind_of(SQLTree::Node::Expression)
  end
end
