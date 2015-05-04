require 'retries'
$stdout.sync = true

def log(logger,message,log_type=:info)

  case log_type
    when :error
      logger.error(message)
    else
      logger.info(message)
  end
  puts message
  $stdout.flush
  
end

desc 'Index a specific list of druids from a pre-assembly log YAML file, a remediate log file, or a simple CSV.  Specify target to index into and log file to index from.'
#Run me: rake log_indexer RAILS_ENV=production target=revs_prod log_file=/tmp/mailander_1.yaml log_type=preassembly 
#Run me: rake log_indexer RAILS_ENV=production target=revs_prod log_file=/tmp/mailander_1_remediation.yaml log_type=remediate 
#Run me: rake log_indexer RAILS_ENV=production target=revs_prod log_file=/tmp/mailander_1.csv log_type=csv # csv must contain a heading called "druid" with the druid to index 

# Examples:
task :log_indexer => :environment do |t, args|

  target = ENV['target'] # must pass in the target so specify solr core to index into
  log_file_path = ENV['log_file'] # must specify pre-assembly log file to index from
  log_type = ENV['log_type'] || 'preassembly' # log type (either preassembly, csv, or remediate), defaults to preassembly
  
  raise 'You must specify a target and log file.' if target.blank? || log_file_path.blank?
  raise 'Log type must be preassembly, remediate or csv.' unless ['preassembly','remediate','csv'].include? log_type
  raise 'Log file not found.' unless File.readable? log_file_path
  
  target_config=BaseIndexer.solr_configuration_class_name.constantize.instance.get_configuration_hash[target]
  
  raise 'Target not found.' if target_config.nil?
  
  if log_type.blank? || log_type == 'preassembly'
    log_completed=:pre_assem_finished
  elsif log_type == 'remediate'
    log_completed=:remediate_completed
  end
  
  output_log_file_name="#{Rails.root}/log/#{File.basename(log_file_path,File.extname(log_file_path))}_indexer_#{Time.now.strftime('%Y%m%d-%H%M%S')}.log"
  my_logger=Logger.new(output_log_file_name) # set up a new log file
  
  start_time=Time.now
  
  errors=0
  indexed=0

  druids=[]
  
  if ['preassembly','remediate'].include? log_type
    YAML.load_stream(IO.read(log_file_path)) { |obj| druids << obj[:pid] if obj[log_completed] == true}  
  else
    csv = CSV.parse(IO.read(log_file_path), :headers => true)
    druids=csv.map { |row| row.to_hash.with_indifferent_access['druid'] }.delete_if {|druid| druid.nil?}
  end
  
  solr_server=BaseIndexer.solr_configuration_class_name.constantize.instance.get_configuration_hash[target]['url']
  
  log my_logger,"** Indexing #{druids.size} druids from #{log_file_path} into solr server #{solr_server} (target=#{target}).  Log file is of type #{log_type}."
  log my_logger,"Indexing started at #{start_time}"

  indexer = BaseIndexer.indexer_class.constantize.new

  counter=0
  
  druids.each do |druid|
  
    druid.gsub!('druid:','')
    counter+=1
    
    begin
      with_retries(:max_tries => 5, :base_sleep_seconds => 3, :max_sleep_seconds => 60) do
        indexer.index(druid,[target]) 
        log my_logger,"#{counter} of #{druids.size}: #{druid}"
        indexed += 1
      end
    rescue  => e
      log my_logger,"ERROR: Failed to index #{druid}: #{e.message}",:error
      errors += 1
    end

  end
  
  log my_logger,"Objects indexed: #{indexed} out of #{druids.size}"
  log(my_logger,"ERRORS Encountered, #{errors} objects not indexed") if errors > 0
  log my_logger,"Completed at #{Time.now}, total time was #{'%.2f' % ((Time.now - start_time)/60.0)} minutes"
  puts "Logged output at #{output_log_file_name}"
  
end
  
desc "Delete a single druid.  It will be deleted from all targets!"
#Run me: rake delete RAILS_ENV=production druid=oo000oo0001
# Examples:
task :delete => :environment do |t, args|

  druid = ENV['druid'] 
  
  raise 'You must specify a druid.' if druid.blank?

  print "Are you sure you wish to delete this druid from all targets? (y/n) "
  STDOUT.flush  
  answer=STDIN.gets.chomp
  
  raise 'STOP!' unless (answer && ['y','yes'].include?(answer.downcase))
      
  puts "** Delete #{druid} druid from all targets."

  indexer = BaseIndexer.indexer_class.constantize.new
  indexer.delete druid.gsub('druid:','')
  
end

desc 'Index a single druid.  Specify target to index into and druid to index.'
#Run me: rake index RAILS_ENV=production target=revs_prod druid=oo000oo0001
# Examples:
task :index => :environment do |t, args|

  target = ENV['target'] # must pass in the target so specify solr core to index into
  druid = ENV['druid'] 
  
  raise 'You must specify a target and druid.' if target.blank? || druid.blank?
  
  target_config=BaseIndexer.solr_configuration_class_name.constantize.instance.get_configuration_hash[target]
  
  raise 'Target not found.' if target_config.nil?

  solr_server=BaseIndexer.solr_configuration_class_name.constantize.instance.get_configuration_hash[target]['url']
  
  puts "** Indexing #{druid} druid into solr server #{solr_server} (target=#{target})."

  indexer = BaseIndexer.indexer_class.constantize.new
  indexer.index(druid.gsub('druid:',''),[target]) 
  
end

desc 'Index an entire collection, including the collection itself and all of its members.  Specify target to index into and collection druid to index.'
#Run me: rake collection_indexer RAILS_ENV=production target=revs_prod collection_druid=oo000oo0001
# Examples:
task :collection_indexer => :environment do |t, args|

  target = ENV['target'] # must pass in the target so specify solr core to index into
  collection_druid = ENV['collection_druid'] 
  
  raise 'You must specify a target and collection druid.' if target.blank? || collection_druid.blank?
  
  target_config=BaseIndexer.solr_configuration_class_name.constantize.instance.get_configuration_hash[target]
  
  raise 'Target not found.' if target_config.nil?

  solr_server=BaseIndexer.solr_configuration_class_name.constantize.instance.get_configuration_hash[target]['url']

  output_log_file_name="#{Rails.root}/log/collection_#{collection_druid}_indexer_#{Time.now.strftime('%Y%m%d-%H%M%S')}.log"
  my_logger=Logger.new(output_log_file_name) # set up a new log file
    
  log my_logger,"** Indexing collection #{collection_druid} druid and all of its members into solr server #{solr_server} (target=#{target})."
 
  start_time=Time.now
  log my_logger,"Indexing started at #{start_time}"

  indexer = BaseIndexer.indexer_class.constantize.new

  df = DorFetcher::Client.new({:service_url => Rails.application.config.dor_fetcher_url})

  collection_druid=collection_druid.gsub('druid:','')
  
  indexer.index(collection_druid,[target]) 
  log my_logger,"Indexed collection: #{collection_druid}"
  
  druids = df.druid_array(df.get_collection(collection_druid, {}))

  log my_logger,"** Found #{druids.size} members of the collection"

  counter=0
  indexed=0
  errors=0
  
  druids.each do |druid|
  
    druid=druid.gsub('druid:','')
    counter+=1
    
    begin
      with_retries(:max_tries => 5, :base_sleep_seconds => 3, :max_sleep_seconds => 60) do
        indexer.index(druid,[target]) 
        log my_logger,"#{counter} of #{druids.size}: #{druid}"
        indexed += 1
      end
    rescue  => e
      log my_logger,"ERROR: Failed to index #{druid}: #{e.message}",:error
      errors += 1
    end

  end
  
  log my_logger,"Objects indexed: #{indexed} out of #{druids.size} + 1 collection druid"
  log(my_logger,"ERRORS Encountered, #{errors} objects not indexed") if errors > 0
  log my_logger,"Completed at #{Time.now}, total time was #{'%.2f' % ((Time.now - start_time)/60.0)} minutes"
  puts "Logged output at #{output_log_file_name}"
  
end  

desc 'ReIndex just the druids that errored out from a previous batch index run. Specify target to index into and batch errored log file to index from.'
#Run me: rake reindexer RAILS_ENV=production target=revs_prod file=./log/index.log
# Examples:
task :reindexer => :environment do |t, args|

  target = ENV['target'] # must pass in the target so specify solr core to index into
  file_path = ENV['file'] # must specify previous indexing log file to index from
  
  raise 'You must specify a target and file.' if target.blank? || file_path.blank?
  raise 'File not found.' unless File.readable? file_path
  
  target_config=BaseIndexer.solr_configuration_class_name.constantize.instance.get_configuration_hash[target]
  
  raise 'Target not found.' if target_config.nil?

  start_time=Time.now
  
  errors=0
  indexed=0

  solr_server=BaseIndexer.solr_configuration_class_name.constantize.instance.get_configuration_hash[target]['url']

  output_log_file_name="#{Rails.root}/log/#{File.basename(file_path,File.extname(file_path))}_reindex_#{Time.now.strftime('%Y%m%d-%H%M%S')}.log"
  my_logger=Logger.new(output_log_file_name) # set up a new log file
    
  log my_logger,"** Indexing errored out druids from #{file_path} into solr server #{solr_server} (target=#{target})."
  log my_logger,"Indexing started at #{start_time}"

  indexer = BaseIndexer.indexer_class.constantize.new

  counter=0

  IO.readlines(file_path).each do |line|

    downcased_line=line.downcase
  
    if downcased_line.include? 'error'
      druid=downcased_line.scan(/[a-z][a-z][0-9][0-9][0-9][a-z][a-z][0-9][0-9][0-9][0-9]/).first
      
      unless druid.blank?    
        begin
          counter+=1
          with_retries(:max_tries => 5, :base_sleep_seconds => 3, :max_sleep_seconds => 60) do
            indexer.index(druid,[target])
            log my_logger,"#{counter}: #{druid}"
            indexed += 1
          end
        rescue  => e
          log my_logger,"ERROR: Failed to index #{druid}: #{e.message}",:error
          errors += 1
        end
      end
      
    end
    
  end
  
  log my_logger,"Objects indexed: #{indexed}"
  log(my_logger,"ERRORS Encountered, #{errors} objects not indexed") if errors > 0
  log my_logger,"Completed at #{Time.now}, total time was #{'%.2f' % ((Time.now - start_time)/60.0)} minutes"
  puts "Logged output at #{output_log_file_name}"
  
end

desc 'Delete the druids specified in the supplied text file (one druid per line, header not necessary).  Be careful!  It will delete from all targets.'
#Run me: rake delete_druids RAILS_ENV=production file=druid_list.txt
# Examples:
task :delete_druids => :environment do |t, args|

  file_path = ENV['file'] # must specify previous indexing log file to index from
  
  raise 'You must specify a druid file.' if file_path.blank?
  raise 'File not found.' unless File.readable? file_path

  print "Are you sure you wish to delete all of the druids from all targets specified in #{file_path}? (y/n) "
  STDOUT.flush  
  answer=STDIN.gets.chomp
  
  raise 'STOP!' unless (answer && ['y','yes'].include?(answer.downcase))
  
  output_log_file_name="#{Rails.root}/log/#{File.basename(file_path,File.extname(file_path))}_delete_#{Time.now.strftime('%Y%m%d-%H%M%S')}.log"
  my_logger=Logger.new(output_log_file_name) # set up a new log file
  
  start_time=Time.now
  
  errors=0
  indexed=0
  
  log my_logger,"** Deleting druids from #{file_path} in all targets."
  log my_logger,"Deleting started at #{start_time}"

  indexer = BaseIndexer.indexer_class.constantize.new

  counter=0

  IO.readlines(file_path).each do |line|

     downcased_line=line.downcase
     druid=downcased_line.scan(/[a-z][a-z][0-9][0-9][0-9][a-z][a-z][0-9][0-9][0-9][0-9]/).first
  
     unless druid.blank?
       counter+=1
    
        begin
          with_retries(:max_tries => 5, :base_sleep_seconds => 3, :max_sleep_seconds => 60) do
            indexer.delete druid
            log my_logger,"#{counter}: #{druid}"
            indexed += 1
          end
        rescue  => e
          log my_logger,"ERROR: Failed to delete #{druid}: #{e.message}",:error
          errors += 1
        end
     end    
  end
  
  log my_logger,"Objects deleted: #{indexed}"
  log(my_logger,"ERRORS Encountered, #{errors} objects not deleted",:error) if errors > 0
  log my_logger,"Completed at #{Time.now}, total time was #{'%.2f' % ((Time.now - start_time)/60.0)} minutes"
  
end