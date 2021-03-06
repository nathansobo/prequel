require 'rubygems'
require 'rspec'

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require 'prequel'
require 'machinist'
require 'prequel/machinist_adaptor'
Sequel.postgres("prequel_test", :host => '/tmp', :port => 15432)
Prequel::DB # touch the Prequel::DB constant so it gets assigned to the connection made above

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.mock_with :rr
  config.include BeLikeQueryMatcher
  config.include TimeTravel

  config.after do
    Prequel::Record.subclasses.each do |subclass|
      subclass.remove_class
    end
    Prequel::Relations::Table.drop_all_tables
    Prequel.clear_session
  end
end
