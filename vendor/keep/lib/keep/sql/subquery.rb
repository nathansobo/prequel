module Keep
  module Sql
    class Subquery < Query
      attr_reader :parent, :relation, :name
      delegate :columns, :to => :relation

      def initialize(parent, relation, name)
        @parent, @name = parent, name
        super(relation)
      end

      def to_sql(query)
        ['(', sql_string(query), ') as ', name].join
      end

      delegate :add_literal, :add_named_table_ref, :add_subquery, :named_table_refs, :to => :parent
    end
  end
end
