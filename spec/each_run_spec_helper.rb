Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr
  config.include BeLikeQueryMatcher
  require 'keep' # module file won't be autoloaded

  config.after do
    Keep::Relations::Table.drop_all_tables
    Keep::Record.subclasses.each do |subclass|
      subclass.remove_class
    end
    Keep.clear_session
  end
end
