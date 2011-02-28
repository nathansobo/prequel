Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr
  config.include BeLikeQueryMatcher
  require 'keep' # module file won't be autoloaded
end
