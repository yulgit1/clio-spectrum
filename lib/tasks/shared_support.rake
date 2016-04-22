
require 'time'    # gives us ISO time formatting
require 'marc'

require File.join(Rails.root.to_s, 'config', 'initializers/aaa_load_app_config.rb')

EXTRACT_SCP_SOURCE = APP_CONFIG['extract_scp_source']

EXTRACTS =  ["full", "incremental", "cumulative", "subset", "law", "test",
             "auth_incremental", "auth_full", "auth_subset"]

BIB_SOLR_URL = Blacklight.connection_config[:url]
BIB_SOLR = RSolr.connect(url: BIB_SOLR_URL)
AUTHORITIES_SOLR = RSolr.connect(url: APP_CONFIG['authorities_solr_url'])


def puts_and_log(msg, level = :info, params = {})
  full_msg = level.to_s + ": " + msg.to_s
  puts full_msg
  unless @logger
    @logger = Logger.new(File.join(Rails.root, "log", "#{Rails.env}_ingest.log"))
    @logger.formatter = Logger::Formatter.new
  end

  if defined?(Rails) && Rails.logger
    Rails.logger.send(level, msg)
  end

  @logger.send(level, msg)

  if params[:alarm]
    if ENV["EMAIL_ON_ERROR"] == "TRUE"
      IngestErrorNotifier.deliver_generic_error(:error => full_msg)
    end
    raise full_msg
  end

end
