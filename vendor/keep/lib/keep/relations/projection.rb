module Keep
  module Relations
    class Projection < Relation
      attr_reader :operand

      def initialize(operand, *symbols)
        @operand = operand
        raise NotImplementedError unless symbols.size == 1
        assign_derived_columns(symbols)
      end

      def get_column(name)
        if name.to_s.include?("__")
          derive_column_from(operand, name)
        else
          derived_columns_by_name[name]
        end
      end

      def columns
        derived_columns.values
      end

      def visit(query)
        operand.visit(query)
        query.select_list = columns.map do |derived_column|
          query.resolve_derived_column(derived_column)
        end
        query.tuple_builder = query.singular_table_refs[projected_table]
      end

      protected
      attr_reader :derived_columns_by_name, :projected_table

      def assign_derived_columns(symbols)
        @derived_columns_by_name = {}
        table_name = symbols.first.to_sym
        @projected_table = operand.get_table(table_name)

        projected_table.columns.map do |column|
          unqualified_name = column.name
          qualified_name = column.qualified_name
          derived_columns_by_name[unqualified_name] = derive_column_from(operand, qualified_name, unqualified_name)
        end
      end
    end
  end
end
