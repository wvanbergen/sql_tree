require 'spec_helper'

describe SQLTree::Node::Expression::Value do

  describe '.parse' do
    it "should not parse a field name" do
      lambda { SQLTree::Node::Expression::Value['field_name'] }.should raise_error(SQLTree::Parser::UnexpectedToken)
    end

    it "should parse an integer value correctly" do
      SQLTree::Node::Expression::Value['123'].value.should == 123
    end

    it "should parse a string correctly" do
      SQLTree::Node::Expression::Value["'123'"].value.should == '123'
    end

    it "should parse a NULL value correctly" do
      SQLTree::Node::Expression::Value['NULL'].value.should == nil
    end

  end
end

describe SQLTree::Node::Expression::Variable do

  describe '.parse' do
    it "should parse a variable name correctly" do
      SQLTree::Node::Expression::Variable['variable'].name.should == 'variable'
    end

    it "should parse a quoted variable name correctly" do
      SQLTree::Node::Expression::Variable['"variable"'].name.should == 'variable'
    end

    it "should raise an error when parsing a reserved keyword as variable" do
      lambda { SQLTree::Node::Expression::Variable['select'] }.should raise_error(SQLTree::Parser::UnexpectedToken)
    end

    it "should parse a quoted reserved keyword as variable name correctly" do
      SQLTree::Node::Expression::Variable['"select"'].name.should == 'select'
    end
  end
end

describe SQLTree::Node::Expression::Field do
  describe '.parse' do
    it "should parse a field name with table name correclty" do
      field = SQLTree::Node::Expression::Field['table.field']
      field.table.should == 'table'
      field.name.should  == 'field'
    end

    it "should parse a field name without table name correclty" do
      field = SQLTree::Node::Expression::Field['field']
      field.table.should be_nil
      field.name.should == 'field'
    end

    it "should parse a quoted field name without table name correclty" do
      field = SQLTree::Node::Expression::Field['"field"']
      field.table.should be_nil
      field.name.should == 'field'
    end

    it "should parse a quoted field name with quoted table name correclty" do
      field = SQLTree::Node::Expression::Field['"table"."field"']
      field.table.should == 'table'
      field.name.should  == 'field'
    end

    it "should parse a quoted field name with non-quoted table name correclty" do
      field = SQLTree::Node::Expression::Field['table."field"']
      field.table.should == 'table'
      field.name.should  == 'field'
    end

    it "should parse a non-quoted field name with quoted table name correclty" do
      field = SQLTree::Node::Expression::Field['"table".field']
      field.table.should == 'table'
      field.name.should  == 'field'
    end
  end
end
