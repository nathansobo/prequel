module Prequel
  module Expressions
    class GreaterThan < Predicate
      def type
        :Gt
      end

      def operator_sql
        '>'
      end
    end
  end
end
