module Keep
  module Relations
    class Projection < Relation
      attr_reader :operand

      def initialize(operand, *symbols)
        @operand = operand
        assign_derived_columns(symbols)
      end

      def get_column(name)
        if name.to_s.include?("__")
          super
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
      attr_reader :projected_table

      def assign_derived_columns(expressions)

        if @projected_table = detect_projected_table(expressions)
          projected_table.columns.map do |column|
            derive(resolve(column.qualified_name.as(column.name)))
          end
        else
          expressions.each do |column_name|
            derive(resolve(column_name))
          end
        end
      end

      def detect_projected_table(args)
        return false unless args.size == 1
        arg = args.first
        if arg.instance_of?(Table)
          table_name = arg.name
        elsif arg.instance_of?(Class) && arg.respond_to?(:table)
          table_name = arg.table.name
        elsif arg.instance_of?(Symbol)
          return false if arg =~ /__/
          table_name = arg
        else
          return false
        end

        operand.get_table(table_name)
      end

      def operands
        [operand]
      end
    end
  end
end
