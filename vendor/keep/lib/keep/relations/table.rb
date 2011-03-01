module Keep
  module Relations
    class Table < Relation
      attr_reader :name, :columns_by_name, :tuple_class
      def initialize(name, tuple_class=nil, &block)
        @name, @tuple_class = name, tuple_class
        @columns_by_name = {}
        TableDefinitionContext.new(self).instance_eval(&block) if block
      end

      def def_column(name, type)
        columns_by_name[name] = Expressions::Column.new(self, name, type)
      end

      def get_column(column_name)
        if column_name.match(/(.+)__(.+)/)
          qualifier, column_name = $1.to_sym, $2.to_sym
          return nil unless qualifier == name
        end
        columns_by_name[column_name]
      end

      def columns
        columns_by_name.values
      end

      def [](col_name)
        "#{name}__#{col_name}".to_sym
      end

      def visit(query)
        query.table_ref = table_ref(query)
      end

      def table_ref(query)
        Sql::TableRef.new(name)
      end

      def all
        DB.fetch(*to_sql).map do |field_values|
          tuple_class.new(field_values)
        end
      end
    end
  end
end