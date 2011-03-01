module Keep
  module Expressions
    class DerivedColumn
      attr_reader :relation, :ancestor
      delegate :name, :to => :ancestor

      def initialize(relation, ancestor)
        @relation, @ancestor = relation, ancestor
      end

      def to_sql(query)
        if qualifier = subquery_name(query)
          "#{qualifier}.#{name}"
        else
          ancestor.to_sql(query)
        end
      end

      def qualified_name(query)
        if qualifier = subquery_name(query)
          "#{qualifier}__#{name}"
        else
          ancestor.qualified_name(query)
        end
      end

      # TODO: move into AbstractColumn?
      def as_qualified
        Sql::QualifiedColumn.new(self)
      end

      protected

      def subquery_name(query)
        query.subqueries[relation].try(:name)
      end

    end
  end
end
