module Keep
  module Relations
    class Projection < Relation
      attr_reader :operand

      def initialize(operand, *symbols)
        @operand = operand
        raise NotImplementedError unless symbols.size == 1
        assign_derived_columns(symbols)
      end

      def columns
        derived_columns.values
      end

      def visit(query)
        operand.visit(query)
        query.select_list = columns.map do |derived_column|
          query.resolve_derived_column(derived_column)
        end
      end

      protected

      def assign_derived_columns(symbols)
        table_name = symbols.first
        table = operand.get_table(table_name)

        table.columns.map do |column|
          unqualified_name = column.name
          qualified_name = column.qualified_name
          derive_column_from(operand, qualified_name, unqualified_name)
        end
      end
    end
  end
end
