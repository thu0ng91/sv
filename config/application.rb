require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NovelReader
  class Application < Rails::Application
    config.autoload_paths += Dir["#{config.root}/lib/classes/**/"]
    config.time_zone = 'Taipei'
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
  end
end
