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

      def as_qualified
        Sql::QualifiedColumn.new(self)
      end

      def inspect
        to_sql(nil)
      end

      def to_sql(query)
        "#{table.name}.#{name}"
      end

      def qualified_name(query)
        "#{table.name}__#{name}"
      end
    end
  end
end