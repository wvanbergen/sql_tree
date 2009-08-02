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
  
  s.files = %w(README.rdoc Rakefile lib lib/sql_tree lib/sql_tree.rb lib/sql_tree/generator.rb lib/sql_tree/node lib/sql_tree/node.rb lib/sql_tree/parser.rb lib/sql_tree/tokenizer.rb spec spec/integration spec/integration/api_spec.rb spec/spec_helper.rb spec/unit spec/unit/parser_spec.rb spec/unit/tokenizer_spec.rb tasks tasks/github-gem.rake)
  s.test_files = %w(spec/integration/api_spec.rb spec/unit/parser_spec.rb spec/unit/tokenizer_spec.rb)
end