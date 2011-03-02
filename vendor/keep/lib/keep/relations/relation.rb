module Keep
  module Relations
    class Relation
      delegate :to_sql, :rows, :all, :to => :query

      def query
        Sql::Query.new.tap do |query|
          visit(query)
        end
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

      def to_relation
        self
      end

      protected

      def derive_column_from(operand, name)
        column = operand.get_column(name)
        derive_column(column) if column
      end

      def derive_column(column)
        Expressions::DerivedColumn.new(self, column)
      end
    end
  end
end