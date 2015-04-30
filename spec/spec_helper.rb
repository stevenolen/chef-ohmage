require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/cacher'

RSpec.configure do |config|
  config.log_level = :fatal

  # Guard against people using deprecated RSpec syntax
  config.raise_errors_for_deprecations!

  # Set a default platform (this is overriden as needed)
  config.platform  = 'ubuntu'
  config.version   = '14.04'

  # Be random!
  config.order = 'random'
end

at_exit { ChefSpec::Coverage.report! }
