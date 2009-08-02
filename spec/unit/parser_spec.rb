require "#{File.dirname(__FILE__)}/../spec_helper"

describe SQLTree::Parser do
  
  before(:all) do
    @parser = SQLTree::Parser.new
  end
  
  context :from_clause do
    it "should parse a simple table" do
      @parser.parse("FROM my_table", :as => :from_clause).should eql([SQLTree::Node::TableImport.new('my_table')])
    end
    
    it "should parse a simple table with implicit alias" do
      @parser.parse("FROM my_table my_alias", :as => :from_clause).should eql([SQLTree::Node::TableImport.new('my_table', 'my_alias')])
    end

    it "should parse a simple table with explicit alias" do
      @parser.parse("FROM my_table AS my_alias", :as => :from_clause).should eql([SQLTree::Node::TableImport.new('my_table', 'my_alias')])
    end

    
  end
  
  context :expressions do
  
    it "should parse a variable" do
      @parser.parse("field", :as => :expression).should eql(SQLTree::Node[:field])
    end

    it "should parse a table field" do
      @parser.parse('tbl.field', :as => :expression).should eql(SQLTree::Node::Field[:tbl, :field])
    end

  
    it "should parse a number" do
      @parser.parse("1.0", :as => :expression).should eql(SQLTree::Node[1.0])
    end

    it "should parse a string" do
      @parser.parse("'str'", :as => :expression).should eql(SQLTree::Node['str'])
    end

    it "should parse a function call without arguments" do
      @parser.parse("NOW()", :as => :expression).should parse_as([:NOW])
    end

    it "should parse a function call with a single numeric argument" do
      @parser.parse("MD5('abc')", :as => :expression).should parse_as([:MD5, 'abc'])
    end

    it "should parse a function call with multiple arguments" do
      @parser.parse("CONCAT('Mr. ', last_name)", :as => :expression).should parse_as([:CONCAT, 'Mr. ', :last_name])
    end

    it "should parse a simple arithmetic operator" do
      @parser.parse("1 + 2", :as => :expression).should parse_as([:plus, 1, 2])
    end
    
    it "should parse a simple comparison" do
      @parser.parse("1 < 2", :as => :expression).should parse_as([:lt, 1, 2])
    end

    it "should parse a simple subexpressions with parenthesis on the start" do
      @parser.parse("(1 + 1) = 2", :as => :expression).should parse_as([:eq, [:plus, 1, 1], 2])
    end

    it "should parse a simple subexpressions with parenthesis on the end" do
      @parser.parse("1 + (1 = 2)", :as => :expression).should parse_as([:plus, 1, [:eq, 1, 2]])
    end

    it "should parse arithmetic operations before comparisons" do
      @parser.parse("1 + 1 = 2", :as => :expression).should parse_as([:eq, [:plus, 1, 1], 2])
    end
    
    it "should parse arithmetic operations before comparisons" do
      @parser.parse("1 + 2 - 3", :as => :expression).should parse_as([:minus, [:plus, 1, 2], 3])
    end
    

    it "should parse arithmetic operations before comparisons" do
      @parser.parse("a and b", :as => :expression).should parse_as([:and, :a, :b])
    end

    it "should parse arithmetic operations before comparisons" do
      @parser.parse("a and b and c", :as => :expression).should parse_as([:and, [:and, :a, :b], :c])
    end

    it "should parse arithmetic operations before comparisons" do
      @parser.parse("a and b or c", :as => :expression).should parse_as([:or, [:and, :a, :b], :c])
    end

    
  end


end
