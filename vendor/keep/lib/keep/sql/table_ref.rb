module Keep
  module Sql
    class TableRef
      attr_reader :relation
      delegate :name, :columns, :tuple_class, :to => :relation

      def initialize(relation)
        @relation = relation
      end

      def to_sql
        name
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
