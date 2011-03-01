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

      def select_list
        (left.columns + right.columns).map do |column|
          column.as_qualified
        end
      end

      def build_tuple(field_values)
        CompositeTuple.new(left.build_tuple(field_values), right.build_tuple(field_values))
      end
    end
  end
end