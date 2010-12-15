require "#{File.dirname(__FILE__)}/../spec_helper"

describe SQLTree::Tokenizer do

  context "recognizing single tokens" do
    it "should tokenize SQL query keywords" do
      SQLTree::Tokenizer.tokenize('WHERE').should tokenize_to(:where)
    end

    it "should tokenize expression keywords" do
      SQLTree::Tokenizer.tokenize('and').should tokenize_to(:and)
    end

    it "should tokenize a begin SQL keyword" do
      SQLTree::Tokenizer.tokenize('BEGIN').should tokenize_to(:begin)
    end

    it "should tokenize muliple separate keywords" do
      SQLTree::Tokenizer.tokenize('SELECT DISTINCT').should tokenize_to(:select, :distinct)
    end

    it "should ignore excessive whitespace" do
      SQLTree::Tokenizer.tokenize("\tSELECT      DISTINCT \r\r").should tokenize_to(:select, :distinct)
    end

    it "should tokenize variables" do
      SQLTree::Tokenizer.tokenize("var").should tokenize_to(sql_var('var'))
    end

    it "should tokenize quoted variables" do
      SQLTree::Tokenizer.tokenize('"var"').should tokenize_to(sql_var('var'))
    end

    it "should tokenize quoted variables even when they are a reserved keyword" do
      SQLTree::Tokenizer.tokenize('"where"').should tokenize_to(sql_var('where'))
    end

    it "should tokenize strings" do
      SQLTree::Tokenizer.tokenize("'hello' '  world  '").should tokenize_to('hello', '  world  ')
    end

    it "should tokenize numbers" do
      SQLTree::Tokenizer.tokenize("1 -2 3.14 -4.0").should tokenize_to(1, -2, 3.14, -4.0)
    end

    it "should tokenize logical operators" do
      SQLTree::Tokenizer.tokenize("< = <> >=").should tokenize_to(:lt, :eq, :ne, :gte)
    end

    it "should tokenize arithmetic operators" do
      SQLTree::Tokenizer.tokenize("+ - / * % || &").should tokenize_to(:plus, :minus, :divide, :multiply, :modulo, :concat, :binary_and)
    end

    it "should tokenize parentheses" do
      SQLTree::Tokenizer.tokenize("(a)").should tokenize_to(lparen, sql_var('a'), rparen)
    end

    it "should tokenize dots" do
      SQLTree::Tokenizer.tokenize('a."b"').should tokenize_to(sql_var('a'), dot, sql_var('b'))
    end

    it "should tokenize commas" do
      SQLTree::Tokenizer.tokenize('a , "b"').should tokenize_to(sql_var('a'), comma, sql_var('b'))
    end

    it "should tokenize postgresql string escape token" do
      SQLTree::Tokenizer.tokenize("E'foo'").should tokenize_to(:string_escape, "foo")
    end

    it "should tokenize postgresql interval statements" do
      SQLTree::Tokenizer.tokenize("interval '2 days'").should tokenize_to(:interval, "2 days")
    end
  end

  # # Combined tokens are disabled for now;
  # # Combination is currently done in the parsing phase.
  # context "combining double keywords" do
  #   it "should tokenize double keywords" do
  #     SQLTree::Tokenizer.tokenize('NOT LIKE').should tokenize_to(:not_like)
  #   end
  # end

  context "when tokenizing full queries or query fragments" do
    it "should tokenize a full SQL query" do
      SQLTree::Tokenizer.tokenize("SELECT a.* FROM a_table AS a WHERE a.id > 1").should tokenize_to(
        :select,  sql_var('a'), dot, :multiply, :from, sql_var('a_table'), :as, sql_var('a'), :where, sql_var('a'), dot, sql_var('id'), :gt, 1)
    end

    it "should tokenize a function call" do
      SQLTree::Tokenizer.tokenize("MD5('test')").should tokenize_to(sql_var('MD5'), lparen, 'test', rparen)
    end

    it "should tokenize a posgresql SET call" do
      SQLTree::Tokenizer.tokenize("SET client_min_messages TO 'panic'").should tokenize_to(:set, sql_var('client_min_messages'), :to, 'panic')
    end
  end

end
