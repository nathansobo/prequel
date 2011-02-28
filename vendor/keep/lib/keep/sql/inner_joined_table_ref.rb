module Keep
  module Sql
    class InnerJoinedTableRef
      attr_reader :left, :right, :predicate
      def initialize(left, right, predicate)
        @left, @right, @predicate = left, right, predicate
      end

      def to_sql(query)
        [left.to_sql(query),
         'inner join',
         right.to_sql(query),
         'on',
         predicate.to_sql(query)
        ].join(' ')
      end
    end
  end
end