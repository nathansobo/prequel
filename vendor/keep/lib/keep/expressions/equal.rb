module Keep
  module Expressions
    class Equal
      attr_reader :left, :right
      def initialize(left, right)
        @left, @right = left, right
      end

      def resolve_columns(*relations)
        Equal.new(resolve_operand(relations, left), resolve_operand(relations, right))
      end

      def to_sql(query)
        "#{left.to_sql(query)} = #{right.to_sql(query)}"
      end

      protected

      def resolve_operand(relations, op)
        if op.instance_of?(Symbol)
          relations.each do |relation|
            if column = relation.get_column(op)
              return column
            end
          end
        else
          op
        end
      end
    end
  end
end