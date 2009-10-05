require "#{File.dirname(__FILE__)}/../spec_helper"

describe SQLTree, 'parsing and generating SQL' do

  it "should parse and generate SQL fo a simple list query" do
    SQLTree["SELECT * FROM table"].to_sql.should == 'SELECT * FROM "table"'
  end
  
  it "should parse and generate the DISTINCT keyword" do
    SQLTree["SELECT DISTINCT * FROM table"].to_sql.should == 'SELECT DISTINCT * FROM "table"'
  end
  
  it 'should parse and generate table aliases' do
    SQLTree["SELECT a.* FROM table AS a"].to_sql.should == 'SELECT "a".* FROM "table" AS "a"'
  end
  
  it "parse and generate a complex SQL query" do
    SQLTree['SELECT a.*,   MD5( a.name )   AS checksum   FROM  table  AS  a , other   WHERE   other.timestamp    >  a.timestamp'].to_sql.should ==
                  'SELECT "a".*, MD5("a"."name") AS "checksum" FROM "table" AS "a", "other" WHERE ("other"."timestamp" > "a"."timestamp")'
  end
end
