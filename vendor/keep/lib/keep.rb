module Keep
  extend self

  def const_missing(name)
    if name == :DB
      const_set(:DB, Sequel::DATABASES.first)
    else
      super
    end
  end

  def table(name, &block)
    Relations::Table.new(name, &block)
  end
end

require 'keep/core_extensions'