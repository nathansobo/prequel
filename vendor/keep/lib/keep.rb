module Keep
  extend ActiveSupport::Autoload
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

  require 'keep/core_extensions'
  autoload :CompositeTuple
  autoload :Expressions
  autoload :Field
  autoload :Record
  autoload :Relations
  autoload :Session
  autoload :Sql
  autoload :Tuple
end
