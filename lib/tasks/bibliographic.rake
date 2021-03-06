


namespace :bibliographic do

  namespace :extract do

    desc "download the latest bibliographic extract from EXTRACT_SCP_SOURCE"
    task :download  do
      extract = EXTRACTS.find { |x| x == ENV["EXTRACT"] }
      puts_and_log("Extract not specified", :error, :alarm => true) unless extract

      temp_dir_name = File.join(Rails.root, "tmp/extracts/#{extract}/current/")
      temp_old_dir_name = File.join(Rails.root, "tmp/extracts/#{extract}/old/")

      FileUtils.rm_rf(temp_old_dir_name)
      FileUtils.mv(temp_dir_name, temp_old_dir_name) if File.exists?(temp_dir_name)
      FileUtils.mkdir_p(temp_dir_name)
      scp_command = "scp #{EXTRACT_SCP_SOURCE}/#{extract}/* " + temp_dir_name
      puts scp_command
      if system(scp_command)
        puts_and_log("Download successful.", :info)
      else
        puts_and_log("Download unsucessful", :error, :alarm => true)
      end


      if  system("gunzip " + temp_dir_name + "*.gz")
        puts_and_log("Gunzip successful", :info)
      else
        puts_and_log("Gunzip unsuccessful", :error, :alarm => true)
      end

    end


    desc "process deletes file"
    task :deletes => :environment do
      extract = EXTRACTS.find { |x| x == ENV["EXTRACT"] }
      extract_files = Dir.glob(File.join(Rails.root, "tmp/extracts/#{extract}/current/*delete*")) if extract
      files_to_read = (ENV["DELETES_FILE"] || extract_files).listify

      puts_and_log("No delete files found.", :info) if files_to_read.empty?

      files_to_read.each do |file|
        if File.exists?(file)
          puts_and_log("Processing file: #{file}", :info)
          ids_to_delete = []

          File.open(file, "r").each do |line|
            ids_to_delete << line
          end

          ids_to_delete.uniq!

          puts_and_log(ids_to_delete.length.to_s + " ids to delete.", :info)
          begin
            solr_delete_ids(ids_to_delete)
            puts_and_log(ids_to_delete.length.to_s + " ids deleted (if in index)", :info)
          rescue => e
            puts_and_log("delete error: " + e.inspect, :error, :alarm => true)
          end

        else
          puts_and_log("File does not exist: #{file}", :error)
        end
      end
    end


    desc "ingest latest bibliographic records"
    task :ingest => :environment do
      extract = EXTRACTS.find { |x| x == ENV["EXTRACT"] }
      extract_files = Dir.glob(File.join(Rails.root, "tmp/extracts/#{extract}/current/*.mrc")) if extract
      files_to_read = (ENV["INGEST_FILE"] || extract_files).listify

      # create new traject indexer
      indexer = Traject::Indexer.new

      # explicity set the settings
      indexer.settings do
         provide "solr.url", Blacklight.connection_config[:url]
         provide 'debug_ascii_progress', true
         provide "log.level", 'debug'
         provide 'processing_thread_pool', '0'
         provide "solr_writer.commit_on_close", "true"
      end

      # load Traject config file (indexing rules)
      indexer.load_config_file(File.join(Rails.root, "config/traject/bibliographic.rb"))

      # index each file 
      files_to_read.each do |filename|
        puts "- processing #{filename}..."
        File.open(filename) do |file|
          indexer.process(file)
        end
      end
    end

    desc "download and ingest latest files"
    task :process => :environment do
      Rake::Task["bibliographic:extract:download"].execute
      puts_and_log("Downloading successful.")

      Rake::Task["bibliographic:extract:deletes"].execute
      puts_and_log("Deletes successful.")

      Rake::Task["bibliographic:extract:ingest"].execute
      puts_and_log("Ingest successful.")


    end
  end


end



