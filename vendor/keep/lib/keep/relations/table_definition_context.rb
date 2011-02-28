module Keep
  module Relations
    class TableDefinitionContext
      attr_reader :table
      def initialize(table)
        @table = table
      end

      def column(name, type)
        table.def_column(name, type)
      end
    end
  end
end