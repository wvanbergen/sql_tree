require "#{File.dirname(__FILE__)}/../spec_helper"

describe SQLTree::Node::UpdateQuery do

  it "should parse a delete query without WHERE clause correctly" do
    update = SQLTree::Node::UpdateQuery["UPDATE table SET field1 = 1, field2 = 5 - 3"]
    update.table.should == 'table'
    update.updates.should have(2).items
    update.updates[0].field.should == 'field1'
    update.updates[0].expression.should == SQLTree::Node::Value.new(1)
    update.updates[1].field.should == 'field2'
    update.updates[1].expression.should be_kind_of(SQLTree::Node::Expression)
    update.where.should be_nil
  end

  it "should parse a delete query without WHERE clause correctly" do
    update = SQLTree::Node::UpdateQuery["UPDATE table SET field = 1 WHERE id = 17"]
    update.table.should == 'table'
    update.updates.should have(1).item
    update.where.should be_kind_of(SQLTree::Node::Expression)
  end
end
