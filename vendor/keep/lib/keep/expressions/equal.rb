module Keep
  module Expressions
    class Equal
      attr_reader :left, :right
      def initialize(left, right)
        @left, @right = left, right
      end

      def resolve_columns(relation)
        Equal.new(resolve_operand(relation, left), resolve_operand(relation, right))
      end

      def to_sql(query)
        "#{left.to_sql(query)} = #{right.to_sql(query)}"
      end

      protected

      def resolve_operand(relation, op)
        if op.instance_of?(Symbol)
          relation.get_column(op)
        else
          op
        end
      end
    end
  end
end