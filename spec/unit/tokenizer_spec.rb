require "#{File.dirname(__FILE__)}/../spec_helper"

describe SQLTree::Tokenizer do
  
  before(:all) do
    @tokenizer = SQLTree::Tokenizer.new
  end
  
  context "recognizing single tokens" do
    it "should tokenize SQL query keywords" do
      @tokenizer.tokenize('WHERE').should tokenize_to(:where)
    end

    it "should tokenize expression keywords" do
      @tokenizer.tokenize('and').should tokenize_to(:and)
    end
    
    it "should tokenize muliple separate keywords" do
      @tokenizer.tokenize('SELECT DISTINCT').should tokenize_to(:select, :distinct)
    end

    it "should ignore excessive whitespace" do
      @tokenizer.tokenize("\tSELECT      DISTINCT \r\r").should tokenize_to(:select, :distinct)
    end

    it "should tokenize variables" do
      @tokenizer.tokenize("var").should tokenize_to(sql_var('var'))
    end

    it "should tokenize quoted variables" do
      @tokenizer.tokenize('"var"').should tokenize_to(sql_var('var'))
    end

    it "should tokenize quoted variables even when they are a reserved keyword" do
      @tokenizer.tokenize('"where"').should tokenize_to(sql_var('where'))
    end

    it "should tokenize strings" do
      @tokenizer.tokenize("'hello' '  world  '").should tokenize_to('hello', '  world  ')
    end
  
    it "should tokenize numbers" do
      @tokenizer.tokenize("1 -2 3.14 -4.0").should tokenize_to(1, -2, 3.14, -4.0)
    end  

    it "should tokenize logical operators" do
      @tokenizer.tokenize("< = <> >=").should tokenize_to(:lt, :eq, :ne, :gte)
    end
    
    it "should tokenize arithmetic operators" do
      @tokenizer.tokenize("+ - / * %").should tokenize_to(:plus, :minus, :divide, :multiply, :modulo)
    end    
    
    it "should tokenize parentheses" do
      @tokenizer.tokenize("(a)").should tokenize_to(lparen, sql_var('a'), rparen)
    end  
    
    it "should tokenize dots" do
      @tokenizer.tokenize('a."b"').should tokenize_to(sql_var('a'), dot, sql_var('b'))
    end  
    
    it "should tokenize commas" do
      @tokenizer.tokenize('a , "b"').should tokenize_to(sql_var('a'), comma, sql_var('b'))
    end
  end
  
  # # Combined tokens are disabled for now; 
  # # Combination is currently done in the parsing phase.
  # context "combining double keywords" do
  #   it "should tokenize double keywords" do
  #     @tokenizer.tokenize('NOT LIKE').should tokenize_to(:not_like)
  #   end
  # end
  
  context "when tokenizing full queries or query fragments" do
    it "should tokenize a full SQL query" do
      @tokenizer.tokenize("SELECT a.* FROM a_table AS a WHERE a.id > 1").should tokenize_to(
        :select,  sql_var('a'), dot, :multiply, :from, sql_var('a_table'), :as, sql_var('a'), :where, sql_var('a'), dot, sql_var('id'), :gt, 1)
    end
    
    it "should tokenize a function call" do
      @tokenizer.tokenize("MD5('test')").should tokenize_to(sql_var('MD5'), lparen, 'test', rparen)
    end
  end
  
end
