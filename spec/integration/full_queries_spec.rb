require "#{File.dirname(__FILE__)}/../spec_helper"

describe SQLTree, 'parsing and generating SQL' do
  
  before(:all) do
    @parser = SQLTree::Parser.new
  end
  
  it "should parse and generate SQL fo a simple list query" do
    @parser.parse("SELECT * FROM tabel").to_sql.should eql('SELECT * FROM "tabel"')
  end
  
  it "should parse and generate the DISTINCT keyword" do
    @parser.parse("SELECT DISTINCT * FROM tabel").to_sql.should eql('SELECT DISTINCT * FROM "tabel"')
  end  
  
  it '...' do
    puts @parser.parse("SELECT tabel.* FROM tabel").to_sql    
  end
end
