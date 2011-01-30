require 'spec_helper'

describe SQLTree, 'for transaction statements' do
  
  it "should parse a BEGIN statement correctly" do
    SQLTree['BEGIN'].should be_kind_of(SQLTree::Node::BeginStatement)
  end

  it "should parse a COMMIT statement correctly" do
    SQLTree['COMMIT'].should be_kind_of(SQLTree::Node::CommitStatement)
  end

  it "should parse a ROLLBACK statement correctly" do
    SQLTree['ROLLBACK'].should be_kind_of(SQLTree::Node::RollbackStatement)
  end
  
end