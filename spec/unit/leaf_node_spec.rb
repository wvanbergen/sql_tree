require "#{File.dirname(__FILE__)}/../spec_helper"

describe SQLTree::Node::Value do
  
  describe '.parse' do
    it "should not parse a field name" do
      lambda { SQLTree::Node::Value['field_name'] }.should raise_error(SQLTree::Parser::UnexpectedToken)
    end

    it "should parse an integer value correctly" do
      SQLTree::Node::Value['123'].value.should == 123
    end

    it "should parse a string correctly" do
      SQLTree::Node::Value["'123'"].value.should == '123'
    end
    
    it "should parse a NULL value correctly" do
      SQLTree::Node::Value['NULL'].value.should == nil
    end
    
  end
end

describe SQLTree::Node::Variable do

  describe '.parse' do
    it "should parse a variable name correctly" do
      SQLTree::Node::Field['variable'].name.should == 'variable'
    end

    it "should parse a quoted variable name correctly" do
      SQLTree::Node::Field['"variable"'].name.should == 'variable'
    end

    it "should raise an error when parsing a reserved keyword as variable" do
      lambda { SQLTree::Node::Field['select'] }.should raise_error(SQLTree::Parser::UnexpectedToken)
    end

    it "should parse a quoted reserved keyword as variable name correctly" do
      SQLTree::Node::Field['"select"'].name.should == 'select'
    end
  end
end

describe SQLTree::Node::Field do
  describe '.parse' do
    it "should parse a field name with table name correclty" do
      field = SQLTree::Node::Field['table.field']
      field.table.should == 'table'
      field.name.should  == 'field'
    end

    it "should parse a field name without table name correclty" do
      field = SQLTree::Node::Field['field']
      field.table.should be_nil
      field.name.should == 'field'
    end

    it "should parse a quoted field name without table name correclty" do
      field = SQLTree::Node::Field['"field"']
      field.table.should be_nil
      field.name.should == 'field'
    end

    it "should parse a quoted field name with quoted table name correclty" do
      field = SQLTree::Node::Field['"table"."field"']
      field.table.should == 'table'
      field.name.should  == 'field'
    end

    it "should parse a quoted field name with non-quoted table name correclty" do
      field = SQLTree::Node::Field['table."field"']
      field.table.should == 'table'
      field.name.should  == 'field'
    end

    it "should parse a non-quoted field name with quoted table name correclty" do
      field = SQLTree::Node::Field['"table".field']
      field.table.should == 'table'
      field.name.should  == 'field'
    end
  end
end
