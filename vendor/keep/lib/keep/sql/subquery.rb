module Keep
  module Sql
    class Subquery < Query
      attr_reader :parent, :relation, :name
      delegate :columns, :to => :relation

      def initialize(parent, relation, name)
        @parent, @name = parent, name
        super(relation)
      end

      delegate :add_literal, :add_singular_table_ref, :add_subquery, :singular_table_refs, :to => :parent

      def to_sql
        ['(', sql_string, ') as ', name].join
      end

      def build_tuple(field_values)
        table_ref.build_tuple(unqualify_field_values(field_values))
      end

      protected

      def unqualify_field_values(field_values)
        Hash[field_values.map do |key, value|
          [key.to_s.gsub(/^#{name}__/, "").to_sym, value]
        end]
      end
    end
  end
end
