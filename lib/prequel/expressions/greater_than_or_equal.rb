module Prequel
  module Expressions
    class GreaterThanOrEqual < Predicate
      def type
        :Gte
      end

      def operator_sql
        '>='
      end
    end
  end
end
