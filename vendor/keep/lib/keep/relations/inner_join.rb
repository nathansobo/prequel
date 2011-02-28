module Keep
  module Relations
    class InnerJoin < Relation
      attr_reader :left, :right, :predicate

      def initialize(left, right, predicate)
        @left, @right = left, right
        @predicate = predicate.to_predicate.resolve_columns(self)
      end

      def get_column(name)
        derive_column_from(left, name) || derive_column_from(right, name)
      end

      def visit(query)
        query.table_ref = table_ref(query)
      end

      def table_ref(query)
        Sql::InnerJoinedTableRef.new(left.table_ref(query), right.table_ref(query), predicate)
      end
    end
  end
end
