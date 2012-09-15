module Prequel
  module Expressions
    class LessThan < Predicate
      def type
        :Lt
      end

      def operator_sql
        '<'
      end
    end
  end
end
