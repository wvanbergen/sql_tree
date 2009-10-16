require "#{File.dirname(__FILE__)}/../spec_helper"

describe SQLTree, 'parsing and generating SQL' do

  before(:each) { SQLTree.identifier_quote_char = '"' }

  it "should parse an generate q query without FROM" do
    SQLTree['SELECT 1'].to_sql.should == 'SELECT 1'
  end
  
  it "should parse and generate MySQL type identifier quotes" do
    SQLTree.identifier_quote_char = "`"
    SQLTree['SELECT `field` FROM `table`'].to_sql.should == 
            'SELECT `field` FROM `table`'
  end

  it "should parse and generate SQL fo a simple list query" do
    SQLTree["SELECT * FROM table"].to_sql.should == 'SELECT * FROM "table"'
  end

  it "should parse and generate the DISTINCT keyword" do
    SQLTree["SELECT DISTINCT * FROM table"].to_sql.should == 'SELECT DISTINCT * FROM "table"'
  end

  it 'should parse and generate table aliases' do
    SQLTree["SELECT a.* FROM table AS a"].to_sql.should == 'SELECT "a".* FROM "table" AS "a"'
  end

  it "should parse and generate an ORDER BY clause" do
    SQLTree["SELECT * FROM table ORDER BY field1, field2"].to_sql.should ==
            'SELECT * FROM "table" ORDER BY "field1", "field2"'
  end

  it "should parse and generate an expression in the SELECT clause" do
    SQLTree['SELECT MD5( a)  AS  a,    b  > 0  AS  test  FROM  table'].to_sql.should ==
            'SELECT MD5("a") AS "a", ("b" > 0) AS "test" FROM "table"'
  end

  it "should parse and generate a complex FROM clause" do
    SQLTree['SELECT * FROM  a  LEFT JOIN  b  ON ( a.id    = b.a_id),      c  AS  d'].to_sql.should ==
            'SELECT * FROM "a" LEFT JOIN "b" ON ("a"."id" = "b"."a_id"), "c" AS "d"'
  end

  it "should parse and generate a WHERE clause" do
    SQLTree['SELECT * FROM  t  WHERE (   field  > 4  OR  NOW() >  timestamp)   AND   other_field  IS NOT NULL'].to_sql.should ==
            'SELECT * FROM "t" WHERE ((("field" > 4) OR (NOW() > "timestamp")) AND ("other_field" IS NOT NULL))'
  end

  it "should parse and generate a GROUP BY and HAVING clause" do
    SQLTree['SELECT SUM( field1 ) FROM  t  GROUP BY  field1,  MD5( field2 ) HAVING  SUM( field1 ) > 10'].to_sql.should ==
            'SELECT SUM("field1") FROM "t" GROUP BY "field1", MD5("field2") HAVING (SUM("field1") > 10)'
  end
  
  it "should parse and generate an INSERT query with field list" do
    SQLTree['INSERT INTO  table  ( field1,   field2)  VALUES (1, 2)'].to_sql.should ==
            'INSERT INTO "table" ("field1", "field2") VALUES (1, 2)'
  end

  it "should parse and generate an INSERT query without field list" do
    SQLTree['INSERT INTO  table  VALUES (1, 2)'].to_sql.should ==
            'INSERT INTO "table" VALUES (1, 2)'
  end
  
  it "should parse and generate an DELETE query without WHERE clause" do
    SQLTree['DELETE FROM  table'].to_sql.should ==
            'DELETE FROM "table"'
  end
  
  it "should parse and generate an DELETE query with WHERE clause" do
    SQLTree['DELETE FROM  table  WHERE  1 = 1'].to_sql.should ==
            'DELETE FROM "table" WHERE (1 = 1)'
  end
  
  it "should parse and generate an UPDATE query without WHERE clause" do
    SQLTree['UPDATE  table  SET  field1  = 1,  field2  = 2'].to_sql.should ==
            'UPDATE "table" SET "field1" = 1, "field2" = 2'
  end

  it "should parse and generate an UPDATE query with WHERE clause" do
    SQLTree['UPDATE  table  SET  field1  = 123 WHERE   id  = 17'].to_sql.should ==
            'UPDATE "table" SET "field1" = 123 WHERE ("id" = 17)'
  end
end
