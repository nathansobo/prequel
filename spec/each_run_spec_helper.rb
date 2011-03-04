Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr
  config.include BeLikeQueryMatcher
  require 'prequel' # module file won't be autoloaded

  config.after do
    Prequel::Relations::Table.drop_all_tables
    Prequel::Record.subclasses.each do |subclass|
      subclass.remove_class
    end
    Prequel.clear_session
  end
end
