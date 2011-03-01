module Keep
  module Sql
    class QualifiedColumn
      attr_reader :column

      def initialize(column)
        @column = column
      end

      def to_sql(query)
        "#{column.to_sql(query)} as #{column.qualified_name(query)}"
      end
    end
  end
end