module Keep
  module Relations
    class Table
      attr_reader :name, :columns_by_name
      def initialize(name, &block)
        @name = name
        @columns_by_name = {}
        DefinitionContext.new(self).instance_eval(&block) if block
      end

      def def_column(name, type)
        columns_by_name[name] = Expressions::Column.new(self, name, type)
      end
    end
  end
end