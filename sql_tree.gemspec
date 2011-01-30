Gem::Specification.new do |s|
  s.name    = 'sql_tree'

  # Do not modify the version and date values by hand, because this will
  # automatically by them gem release script.
  s.version = "0.2.0"
  s.date    = "2011-01-30"

  s.summary = "A pure Ruby library to represent SQL queries with a syntax tree for inspection and modification."
  s.description = <<-EOS
    The library can parse an SQL query (a string) to represent the query using
    a syntax tree, and it can generate an SQL query from a syntax tree. The 
    syntax tree ca be used to inspect to query, or to modify it.
  EOS

  s.authors  = 'Willem van Bergen'
  s.email    = 'willem@vanbergen.org'
  s.homepage = 'http://wiki.github.com/wvanbergen/sql_tree'

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '~> 2')

  s.rdoc_options << '--title' << s.name << '--main' << 'README.rdoc' << '--line-numbers' << '--inline-source'
  s.extra_rdoc_files = ['README.rdoc']

  # Do not modify the files and test_files values by hand, because this will
  # automatically by them gem release script.
  s.files = %w(.gitignore .infinity_test Gemfile LICENSE README.rdoc Rakefile lib/sql_tree.rb lib/sql_tree/node.rb lib/sql_tree/node/begin_statement.rb lib/sql_tree/node/commit_statement.rb lib/sql_tree/node/delete_query.rb lib/sql_tree/node/expression.rb lib/sql_tree/node/insert_query.rb lib/sql_tree/node/join.rb lib/sql_tree/node/ordering.rb lib/sql_tree/node/rollback_statement.rb lib/sql_tree/node/select_declaration.rb lib/sql_tree/node/select_query.rb lib/sql_tree/node/set_query.rb lib/sql_tree/node/source.rb lib/sql_tree/node/table_reference.rb lib/sql_tree/node/update_query.rb lib/sql_tree/parser.rb lib/sql_tree/token.rb lib/sql_tree/tokenizer.rb spec/helpers/matchers.rb spec/integration/api_spec.rb spec/integration/parse_and_generate_spec.rb spec/spec_helper.rb spec/unit/control_statements_spec.rb spec/unit/delete_query_spec.rb spec/unit/expression_node_spec.rb spec/unit/insert_query_spec.rb spec/unit/leaf_node_spec.rb spec/unit/select_query_spec.rb spec/unit/set_query_spec.rb spec/unit/tokenizer_spec.rb spec/unit/update_query_spec.rb sql_tree.gemspec tasks/github-gem.rb)
  s.test_files = %w(spec/integration/api_spec.rb spec/integration/parse_and_generate_spec.rb spec/unit/control_statements_spec.rb spec/unit/delete_query_spec.rb spec/unit/expression_node_spec.rb spec/unit/insert_query_spec.rb spec/unit/leaf_node_spec.rb spec/unit/select_query_spec.rb spec/unit/set_query_spec.rb spec/unit/tokenizer_spec.rb spec/unit/update_query_spec.rb)
end
