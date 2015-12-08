{<img src="https://travis-ci.org/sul-dlss/base_indexer.svg?branch=master" alt="Build Status" />}[https://travis-ci.org/sul-dlss/base_indexer]  {<img src="https://coveralls.io/repos/sul-dlss/base_indexer/badge.svg" alt="Coverage Status" />}[https://coveralls.io/r/sul-dlss/base_indexer]

# BaseIndexer

## Running tests

Clone from github.
  rake # first time setup and to generate all docs
  bundle exec rake spec # just run the tests next time around


## Steps to hook the base_indexer engine in your app
### Generate new rails app
rails new my_indexer_app

### Edit Gemfile and add the base_indexer gem name
gem 'base_indexer'

### Run bundle install to download the gem
bundle install

### Mount the engine in your favorite domain.
mount BaseIndexer::Engine, at: '/items'

## Basic configuration
The engine is looking for the following values

config.solr_config_file_path = "#{config.root}/config/solr.yml"
DiscoveryIndexer::PURL_DEFAULT='https://purl.stanford.edu'


## Advanced features

The engine gives the developer the ability to extend any of its classes

To extend any of indexer features (purl-reader, mods-reader, mapper, solr-writer)

1. Create a new class that inherits from BaseIndexer::MainIndexerEngine
2. Create a new file named config/initializers/base_indexer.rb
3. In this file, add the following line. replace 'MyIndexerClassName' with the fully qualifed actual class name. The name should be between double qoutes
BaseIndexer.indexer_class = "MyIndexerClassName"
4. In the new indexer class, you can override any of the functions that you need to change its implementation. For example, if you need to use a new mapper, you will override map function.

To extend mapper functionality.
1. Create a new class e.g., MyMapper that inherits from GeneralMapper or IndexMapper.
2. Implement MyMapper.map to converts the input to solr doc hash.
3. Override MyIndexerClassName.map to call your new class instead of the default one.

## Rake Tasks For Indexing Druids

All rake tasks that perform batch indexing will generate log files in the "log" folder within the app itself.  You can tail the log file to watch the progress.  The
log file is also useful since you can pass it to the "reindexer" rake task to retry just the errored out druids.  The name of the log file will depend on which
rake task you are running, and will be timestamped to be unique.

### Index a single druid:

rake index RAILS_ENV=production target=revs_prod druid=oo000oo0001

### Index a list of druids from a pre-assembly run, a remeditaion run, or a simple CSV:

rake log_indexer RAILS_ENV=production target=revs_prod log_file=/tmp/mailander_1.yaml log_type=preassembly  = preassembly run
nohup rake log_indexer RAILS_ENV=production target=revs_prod log_file=/tmp/mailander_1.yaml log_type=preassembly &  = for a long running process, which will be most runs that have more than a few dozen druids, nohup it

rake log_indexer RAILS_ENV=production target=revs_prod log_file=/tmp/mailander_1_remediate.yaml log_type=remediate = remediation run

rake log_indexer RAILS_ENV=production target=revs_prod log_file=/tmp/mailander.csv log_type=csv = a simple csv file -- it must have a header line, with the header of "druid" definining the items you wish to index

### Index an entire collection, including the collection itself, along with all of its members (be sure to check the dor-fetcher-url parameter in the Rails environment you are running under to be sure it is connecting where you expect):

rake collection_indexer RAILS_ENV=production target=revs_prod collection_druid=oo000oo0001
nohup rake collection_indexer RAILS_ENV=production target=revs_prod collection_druid=oo000oo0001 &   = for a long running process, e.g. a collection with more than a few dozen druids, nohup it

### Re-Index Just Errored Out Items

If you had errors when indexing from a preassembly/remediation log or from indexing an entire collection, you can re-run the errored out druids only with the log file.  All log files are kept in the log folder in the revs-indexer-service app.

rake reindexer RAILS_ENV=production target=revs_prod file=log/logfile.log

nohup rake reindexer RAILS_ENV=production target=revs_prod file=log/logfile.log & = probably no need to nohup unless there were alot of errors

### Delete Druids

Delete a list of druids specified in a CSV/txt file.  Be careful, this will delete from all targets!  Put one druid per line, no header is necessary.

rake delete_druids RAILS_ENV=production file=druid_list.txt

### Delete a single druid

rake delete RAILS_ENV=production druid=oo000oo0001
