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

  def session
    Thread.current[:keep_session] ||= Session.new
  end

  def clear_session
    Thread.current[:keep_session] = nil if Thread.current[:keep_session]
  end
end

require 'keep/core_extensions'