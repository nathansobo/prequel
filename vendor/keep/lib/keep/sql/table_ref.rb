module Keep
  module Sql
    class TableRef
      attr_reader :relation, :query_columns
      delegate :name, :columns, :tuple_class, :to => :relation

      def initialize(relation)
        @relation = relation
        @query_columns = {}
      end

      def to_sql
        name
      end

      def resolve_column(column)
        query_columns[column] ||= Sql::QueryColumn.new(self, column.name)
      end

      def build_tuple(field_values)
        specific_field_values = {}
        field_values.each do |field_name, value|
          if field_name =~ /(.+)__(.+)/
            qualifier, field_name = $1.to_sym, $2.to_sym
            next unless qualifier == name
          end
          specific_field_values[field_name] = value
        end
        tuple_class.new(specific_field_values)
      end
    end
  end
end
