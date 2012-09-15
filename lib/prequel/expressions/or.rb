module Prequel
  module Expressions
    class Or < Predicate
      def type
        :Or
      end

      def operator_sql
        'or'
      end

      def parenthesize?
        true
      end
    end
  end
end
