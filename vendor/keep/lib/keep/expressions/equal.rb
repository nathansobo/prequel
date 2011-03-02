module Keep
  module Expressions
    class Equal
      attr_reader :left, :right
      def initialize(left, right)
        @left, @right = left, right
      end
      
      def resolve_in_relations(*relations)
        Equal.new(left.resolve_in_relations(*relations), right.resolve_in_relations(*relations))
      end

      def to_sql(query)
        "#{left.to_sql(query)} = #{right.to_sql(query)}"
      end
    end
  end
end