require "#{File.dirname(__FILE__)}/../spec_helper"

describe SQLTree::Node::SetQuery do

  it "should parse a set query correctly" do
    set = SQLTree::Node::SetQuery["SET foo TO 'var'"]
    set.variable.should == SQLTree::Node::Expression::Field.new("foo")
    set.value.should == SQLTree::Node::Expression::Value.new("var")
  end

end
