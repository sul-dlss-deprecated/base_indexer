require 'active_support/core_ext/numeric/bytes'
require 'config'

module BaseIndexer
  class Engine < ::Rails::Engine
    isolate_namespace BaseIndexer

    # Initialize memory store cache with 50 MB size
    config.cache_store = [:memory_store, { size: 64.megabytes }]

    config.generators do |g|
      g.test_framework :rspec
    end
    config.app_version = '0.0'
    config.app_name = '[You have to override this name in your app]'

    config.after_initialize do
      # Initializes the DiscoveryIndexer log with Rails logger, so all the messages will go to
      #   the same log file
      DiscoveryIndexer::Logging.logger = Rails.logger
    end
  end
end
