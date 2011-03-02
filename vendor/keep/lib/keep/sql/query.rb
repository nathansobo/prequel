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
        [sql_string, literals]
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

      def sql_string
        ["select",
          select_clause_sql,
          "from",
          from_clause_sql,
          where_clause_sql,
        ].compact.join(" ")
      end

      def select_clause_sql
        if select_list
          select_list.map {|column| column.to_select_clause_sql}.join(', ')
        else
          '*'
        end
      end

      def from_clause_sql
        table_ref.to_sql
      end

      def where_clause_sql
        return nil if conditions.empty?
        'where ' + conditions.map do |condition|
          condition.to_sql
        end.join(' and ')
      end
    end
  end
end