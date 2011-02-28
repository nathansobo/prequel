  module Keep
    module Expressions
      class Column
      attr_reader :table, :name, :type

      def initialize(table, name, type)
        @table, @name, @type = table, name, type
      end

      def eq(other)
        Equal.new(self, other)
      end

      def inspect
        to_sql(nil)
      end

      def to_sql(query)
        "#{table.name}.#{name}"
      end
    end
  end
end