module Keep
  module Sql
    class DerivedColumn
      attr_reader :subquery, :name, :ancestor

      def initialize(subquery, name, ancestor)
        @subquery, @name, @ancestor = subquery, name, ancestor
      end

      def to_sql(query)
        "#{subquery.name}.#{name}"
      end

      def to_select_clause_sql(query)
        "#{ancestor.to_sql(query)} as #{name}"
      end

      def qualified_name
        "#{subquery.name}__#{name}"
      end
    end
  end
end
