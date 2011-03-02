module Keep
  module Sql
    class DerivedQueryColumn
      attr_reader :subquery, :name, :ancestor

      def initialize(subquery, name, ancestor)
        @subquery, @name, @ancestor = subquery, name, ancestor
      end

      def to_sql
        "#{subquery.name}.#{name}"
      end

      def to_select_clause_sql
        "#{ancestor.to_sql} as #{name}"
      end

      def qualified_name
        "#{subquery.name}__#{name}"
      end
    end
  end
end
