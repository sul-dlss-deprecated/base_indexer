begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rspec/core'
require 'rspec/core/rake_task'
require 'yard'
require 'yard/rake/yardoc_task'

Bundler::GemHelper.install_tasks



APP_RAKEFILE = File.expand_path("../spec/internal/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'
Dir[File.join(File.dirname(__FILE__), 'tasks/**/*.rake')].each {|f| load f }

# Travis ci task
task :default => :ci  
desc "run continuous integration suite (tests, coverage, docs)" 
task :ci => [:rspec, :doc]

# Run rspec
task :spec => :rspec
RSpec::Core::RakeTask.new(:rspec) do |spec|
  spec.rspec_opts = ["-c", "-f progress", "--tty", "-r ./spec/spec_helper.rb"]
end

# Use yard to build docs
begin
  project_root = File.expand_path(File.dirname(__FILE__))
  doc_dest_dir = File.join(project_root, 'doc')

  YARD::Rake::YardocTask.new(:doc) do |yt|
    yt.files = Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) +
                 [ File.join(project_root, 'README.rdoc') ]
    yt.options = ['--output-dir', doc_dest_dir, '--readme', 'README.rdoc', '--title', 'Discovery Indexer Documentation']
  end
rescue LoadError
  desc "Generate YARD Documentation"
  task :doc do
    abort "Please install the YARD gem to generate rdoc."
  end
end  



