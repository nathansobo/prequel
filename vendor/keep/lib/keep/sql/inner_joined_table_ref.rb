module Keep
  module Sql
    class InnerJoinedTableRef
      attr_reader :left, :right, :predicate
      def initialize(left, right, predicate)
        @left, @right, @predicate = left, right, predicate
      end

      def to_sql
        [left.to_sql,
         'inner join',
         right.to_sql,
         'on',
         predicate.to_sql
        ].join(' ')
      end

      def select_list
        columns.map(&:as_qualified)
      end

      def columns
        left.columns + right.columns
      end

      def build_tuple(field_values)
        CompositeTuple.new(left.build_tuple(field_values), right.build_tuple(field_values))
      end
    end
  end
end