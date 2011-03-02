module Keep
  module Sql
    class Query
      attr_accessor :select_list
      attr_reader :table_ref, :conditions, :literals, :named_table_refs, :subquery_count

      def initialize(relation)
        @relation = relation
        @conditions = []
        @literals = {}
        @named_table_refs = { relation => self }
        @subquery_count = 0
        relation.visit(self)
      end

      def table_ref=(table_ref)
        raise "A table ref has already been assigned" if @table_ref
        @table_ref = table_ref
      end

      def add_condition(predicate)
        conditions.push(predicate)
      end

      def add_literal(literal)
        "v#{literals.size + 1}".to_sym.tap do |placeholder|
          literals[placeholder] = literal
        end
      end

      def add_named_table_ref(relation, table_ref)
        named_table_refs[relation] = table_ref
      end

      def add_subquery(relation)
        @subquery_count += 1
        add_named_table_ref(relation, Subquery.new(self, relation, "t#{subquery_count}"))
      end

      def to_sql
        [sql_string(self), literals]
      end

      def select_clause_sql(query)
        if select_list
          select_list.map {|column| column.to_select_clause_sql(query)}.join(', ')
        else
          '*'
        end
      end

      def where_clause_sql(query)
        return nil if conditions.empty?
        'where ' + conditions.map do |condition|
          condition.to_sql(query)
        end.join(' and ')
      end

      def from_clause_sql(query)
        table_ref.to_sql(query)
      end

      def rows
        DB[*to_sql]
      end

      def all
        rows.map do |field_values|
          table_ref.build_tuple(field_values)
        end
      end

      protected

      def sql_string(query)
        ["select",
          select_clause_sql(query),
          "from",
          from_clause_sql(query),
          where_clause_sql(query)
        ].compact.join(" ")
      end
    end
  end
end