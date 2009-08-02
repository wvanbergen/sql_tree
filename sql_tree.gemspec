Gem::Specification.new do |s|
  s.name    = 'sql_tree'
  s.version = '0.0.1'
  s.date    = '2009-08-02'
  
  s.summary = "A pure Ruby library to represent SQL queries as trees of nodes."
  s.description = "To make it easier to build and manipulate SQL queries, sql_tree can parse an SQL query to represent it as a tree of nodes and can generate an SQL query given a tree as input"
  
  s.authors  = 'Willem van Bergen'
  s.email    = 'willem@vanbergen.org'
  s.homepage = 'http://wiki.github.com/wvanbergen/sql_tree'
  
  s.has_rdoc = true
  s.rdoc_options << '--title' << s.name << '--main' << 'README.rdoc' << '--line-numbers' << '--inline-source'
  s.extra_rdoc_files = ['README.rdoc']
  
  s.files = %w(LICENSE README.rdoc Rakefile init.rb lib lib/scoped_search lib/scoped_search.rb lib/scoped_search/query_conditions_builder.rb lib/scoped_search/query_language_parser.rb lib/scoped_search/reg_tokens.rb tasks tasks/database_tests.rake tasks/github-gem.rake test test/database.yml test/integration test/integration/api_test.rb test/lib test/lib/test_models.rb test/lib/test_schema.rb test/test_helper.rb test/unit test/unit/query_conditions_builder_test.rb test/unit/query_language_test.rb test/unit/search_for_test.rb)
  s.test_files = %w(test/integration/api_test.rb test/unit/query_conditions_builder_test.rb test/unit/query_language_test.rb test/unit/search_for_test.rb)
end