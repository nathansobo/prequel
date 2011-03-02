module Keep
  module Sql
    class Column
      attr_reader :table_ref, :name
      def initialize(table_ref, name)
        @table_ref, @name = table_ref, name
      end

      def to_sql(query)
        "#{table_ref.name}.#{name}"
      end

      def to_select_clause_sql(query)
        to_sql(query)
      end

      def qualified_name
        "#{table_ref.name}__#{name}"
      end
    end
  end
end
