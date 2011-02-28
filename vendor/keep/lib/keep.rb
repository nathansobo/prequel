module Keep
  extend self

  def table(name, &block)
    Relations::Table.new(name, &block)
  end
end

require 'keep/core_extensions'