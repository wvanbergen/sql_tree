require "#{File.dirname(__FILE__)}/../spec_helper"

describe SQLTree::Node::DeleteQuery do

  it "should parse a delete query without WHERE clause correctly" do
    insert = SQLTree::Node::DeleteQuery["DELETE FROM table"]
    insert.table.should == 'table'
    insert.expression.should be_nil
  end

  it "should parse a delete query without WHERE clause correctly" do
    insert = SQLTree::Node::DeleteQuery["DELETE FROM table WHERE 1 = 1"]
    insert.table.should == 'table'
    insert.expression.should be_kind_of(SQLTree::Node::Expression)
  end
end
