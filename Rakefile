require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

def ex(sql)
  sql.gsub! "\n", " "
  sh "psql -h localhost drturbotax_development -c '#{sql}'"
end

task :maketables do
  ex "DROP TABLE IF EXISTS fml_specs"
  ex <<-SQL
  CREATE TABLE IF NOT EXISTS fml_specs (
    id varchar(255),
    title text,
    version text,
    spec text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
  )
  SQL

  ex "DROP TABLE IF EXISTS fml_docs"
  ex <<-SQL
    CREATE TABLE IF NOT EXISTS fml_docs (
      id varchar(255),
      spec_id varchar(255),
      doc json,
      created_at timestamp without time zone,
      updated_at timestamp without time zone
    )
  SQL
end
