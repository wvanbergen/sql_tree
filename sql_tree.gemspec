Gem::Specification.new do |s|
  s.name    = 'sql_tree'

  # Do not modify the version and date values by hand, because this will
  # automatically by them gem release script.
  s.version = '0.0.1'
  s.date    = '2009-08-02'

  s.summary = "A pure Ruby library to represent SQL queries with a syntax tree for inspection and modification."
  s.description = <<-EOS
    The library can parse an SQL query (a string) to represent the query using
    a syntax tree, and it can generate an SQL query from a syntax tree. The 
    syntax tree ca be used to inspect to query, or to modify it.
  EOS

  s.authors  = 'Willem van Bergen'
  s.email    = 'willem@vanbergen.org'
  s.homepage = 'http://wiki.github.com/wvanbergen/sql_tree'

  s.rdoc_options << '--title' << s.name << '--main' << 'README.rdoc' << '--line-numbers' << '--inline-source'
  s.extra_rdoc_files = ['README.rdoc']

  # Do not modify the files and test_files values by hand, because this will
  # automatically by them gem release script.
  s.files = %w(README.rdoc Rakefile lib lib/sql_tree lib/sql_tree.rb lib/sql_tree/generator.rb lib/sql_tree/node lib/sql_tree/node.rb lib/sql_tree/parser.rb lib/sql_tree/token.rb lib/sql_tree/tokenizer.rb spec spec/integration spec/integration/api_spec.rb spec/lib spec/lib/matchers.rb spec/spec_helper.rb spec/unit spec/unit/parser_spec.rb spec/unit/tokenizer_spec.rb tasks tasks/github-gem.rake)
  s.test_files = %w(spec/integration/api_spec.rb spec/unit/parser_spec.rb spec/unit/tokenizer_spec.rb)
end
