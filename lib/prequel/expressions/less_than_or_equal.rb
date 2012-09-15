module Prequel
  module Expressions
    class LessThanOrEqual < Predicate
      def type
        :Lte
      end

      def operator_sql
        '<='
      end
    end
  end
end
