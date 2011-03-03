module Keep
  module Relations
    class Selection < Relation
      attr_reader :operand, :predicate

      def initialize(operand, predicate)
        @operand = operand
        @predicate = predicate.to_predicate.resolve_in_relations(operand)
      end

      def get_column(name)
        derive_column_from(operand, name)
      end

      delegate :get_table, :to => :operand

      def columns
        operand.columns.map do |column|
          derive_column(column)
        end
      end

      def visit(query)
        operand.visit(query)
        query.add_condition(predicate.resolve_in_query(query))
      end
    end
  end
end
