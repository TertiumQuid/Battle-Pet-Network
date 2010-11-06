namespace :db do
  desc "Raise an error if the RAILS_ENV is production"
  task :production_filter do
    # raise "Database cannot be rebuilt in production!" if RAILS_ENV == 'production'
  end
  
  desc "Drop, create, migrate then seed the database"
  task(:rebuild => :environment) do
    Rake::Task['db:production_filter'].invoke    
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
    Rake::Task['db:test:prepare'].invoke
  end
end