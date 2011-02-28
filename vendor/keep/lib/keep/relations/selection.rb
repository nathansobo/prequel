module Keep
  module Relations
    class Selection < Relation
      attr_reader :operand, :predicate

      def initialize(operand, predicate)
        @operand = operand
        @predicate = predicate.to_predicate.resolve_columns(self)
      end

      def get_column(name)
        operand.get_column(name)
      end

      def visit(query)
        query.add_condition(predicate)
        operand.visit(query)
      end
    end
  end
end
