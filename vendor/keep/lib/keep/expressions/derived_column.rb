module Keep
  module Expressions
    class DerivedColumn
      attr_reader :relation, :ancestor, :qualified
      delegate :name, :to => :ancestor

      def initialize(relation, ancestor, qualified)
        @relation, @ancestor, @qualified = relation, ancestor, qualified
      end

      def resolve_in_query(query)
        if subquery = query.named_table_refs[relation]
          resolved_ancestor = ancestor.resolve_in_query(query)
          resolved_name = qualified ? resolved_ancestor.qualified_name : name
          Sql::DerivedColumn.new(subquery, resolved_name, resolved_ancestor)
        else
          ancestor.resolve_in_query(query)
        end
      end

      protected

      def subquery_name(query)
        query.subqueries[relation].try(:name)
      end
    end
  end
end
