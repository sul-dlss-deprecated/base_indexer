require 'config'

Config.setup do |config|
  # Name of the constant exposing loaded settings
  config.const_name = 'Settings'
end
