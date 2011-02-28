module Keep
  module Relations
    class Relation
      def to_sql
        Sql::Query.new.tap do |query|
          visit(query)
        end.to_sql
      end

      def join(right, predicate)
        InnerJoin.new(self, right, predicate)
      end

      def where(predicate)
        Selection.new(self, predicate)
      end

      def table_ref(query)
        query.add_subquery(self)
      end

      protected

      def derive_column_from(operand, name)
        column = operand.get_column(name)
        Expressions::DerivedColumn.new(self, column) if column
      end
    end
  end
end