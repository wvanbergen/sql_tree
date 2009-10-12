require "#{File.dirname(__FILE__)}/../spec_helper"

describe SQLTree::Node::InsertQuery do
  
  it "should parse an insert query without field list correctly" do
    insert = SQLTree::Node::InsertQuery["INSERT INTO table VALUES (1, 'two', 3+4, MD5('$ecret'))"]
    insert.table.should == 'table'
    insert.fields.should be_nil
    insert.values.should have(4).items
    insert.values[0].should == SQLTree::Node::Value.new(1)
    insert.values[1].should == SQLTree::Node::Value.new('two')
    insert.values[2].should be_kind_of(SQLTree::Node::Expression::BinaryOperator)
    insert.values[3].should be_kind_of(SQLTree::Node::Expression::FunctionCall)
  end
  
  it "should parse an insert query with field list" do
    insert = SQLTree::Node::InsertQuery['INSERT INTO table ("field1", "field2") VALUES (1, 2)']
    insert.table.should == 'table'
    insert.fields.should have(2).items
    insert.fields[0].should == SQLTree::Node::Variable.new('field1')
    insert.fields[1].should == SQLTree::Node::Variable.new('field2')
    insert.values.should have(2).items
  end
end
