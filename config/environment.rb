# RAILS_ENV = ENV['RAILS_ENV'] || 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  config.gem "will_paginate"
  config.gem "authlogic"
  config.gem "facebooker"
  config.gem "searchlogic"
  config.gem 'flexmock'
  config.gem 'rdiscount'
  config.gem "activemerchant", :lib => "active_merchant"

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  
  # load all models and libs in subdirectories
  ['app/models','lib'].each do |path|
    config.load_paths += Dir["#{RAILS_ROOT}/#{path}/*"].find_all { |f| File.stat(f).directory? }
  end    
end

# enables detailed logging
ActiveRecord::Base.logger.level = Logger::DEBUG