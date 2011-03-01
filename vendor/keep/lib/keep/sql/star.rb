module Keep
  module Sql
    class Star
      attr_reader :table_ref
      def initialize(table_ref)
        @table_ref = table_ref
      end

      def to_sql(query)
        "*"
      end

      def qualify
        table_ref.columns
      end
    end
  end
end