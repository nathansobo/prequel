module Keep
  module Expressions
    class DerivedColumn
      attr_reader :relation, :ancestor
      delegate :name, :to => :ancestor

      def initialize(relation, ancestor)
        @relation, @ancestor = relation, ancestor
      end

      def to_sql(query)
        if subquery = query.subqueries[relation]
          "#{subquery.name}.#{name}"
        else
          ancestor.to_sql(query)
        end
      end
    end
  end
end
