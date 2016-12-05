require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NovelReader
  class Application < Rails::Application
    config.time_zone = 'Taipei'
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
  end
end
