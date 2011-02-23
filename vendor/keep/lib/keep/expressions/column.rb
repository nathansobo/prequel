module Keep
  module Expressions
    class Column
      attr_reader :table, :name, :type

      def initialize(table, name, type)
        @table, @name, @type = table, name, type
      end
    end
  end
end