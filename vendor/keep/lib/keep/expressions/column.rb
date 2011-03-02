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

      def resolve_in_query(query)
        Sql::Column.new(query.named_table_refs[table], name)
      end
    end
  end
end