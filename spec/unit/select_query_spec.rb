require "#{File.dirname(__FILE__)}/../spec_helper"

describe SQLTree::Node::Source do

  it "should parse the table name correctly" do
    SQLTree::Node::Source['table AS a'].table.should == 'table'
  end

  it "should parse the alias correctly when using the AS keyword" do
    SQLTree::Node::Source['table AS a'].table_alias.should == 'a'
  end

  it "should not require the AS keyword for a table alias" do
    SQLTree::Node::Source['table AS a'].should == SQLTree::Node::Source['table a']
  end

  it "should parse a table name without alias" do
    SQLTree::Node::Source['table'].table.should == "table"
    SQLTree::Node::Source['table'].table_alias.should be_nil
  end

  it "should have no joins" do
    SQLTree::Node::Source['table'].joins.should be_empty
  end
end

describe SQLTree::Node::Join do

  it "should parse a join table" do
    SQLTree::Node::Join['LEFT JOIN table ON other.field = table.field'].table.should == 'table'
  end
  
  it "should parse the join type" do
    SQLTree::Node::Join['LEFT JOIN table ON other.field = table.field'].join_type.should == :left
  end
  
  it "should parse the join expression" do
    SQLTree::Node::Join['LEFT JOIN table ON other.field = table.field'].join_expression.should be_kind_of(SQLTree::Node::Expression)
  end
  
  it "should not parse a table alias" do
    SQLTree::Node::Join['LEFT JOIN table ON other.field = table.field'].table_alias.should be_nil
  end  
  
  it "should parse a table alias with AS" do
    SQLTree::Node::Join['LEFT JOIN table AS t ON other.field = table.field'].table_alias.should == 't'
  end
  
  it "should parse a table alias without AS" do
    SQLTree::Node::Join['LEFT JOIN table t ON other.field = table.field'].table_alias.should == 't'
  end
end
