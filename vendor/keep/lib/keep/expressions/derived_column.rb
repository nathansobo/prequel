module Keep
  module Expressions
    class DerivedColumn
      attr_reader :relation, :ancestor
      delegate :name, :to => :ancestor

      def initialize(relation, ancestor)
        @relation, @ancestor = relation, ancestor
      end

      def resolve_in_query(query)
        if subquery = query.named_table_refs[relation]
          subquery.resolve_derived_column(self)
        else
          ancestor.resolve_in_query(query)
        end
      end
    end
  end
end
