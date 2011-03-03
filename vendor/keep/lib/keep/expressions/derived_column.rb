module Keep
  module Expressions
    class DerivedColumn
      attr_reader :relation, :ancestor, :alias_name
      delegate :origin, :to => :ancestor

      def initialize(relation, ancestor, alias_name)
        @relation, @ancestor, @alias_name = relation, ancestor, alias_name
      end

      def name
        alias_name || ancestor.name
      end

      def resolve_in_query(query)
        if subquery = query.singular_table_refs[relation]
          subquery.resolve_derived_column(self)
        else
          ancestor.resolve_in_query(query)
        end
      end
    end
  end
end
