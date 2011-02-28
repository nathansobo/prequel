module Keep
  module Sql
    class TableRef
      attr_reader :name
      def initialize(name)
        @name = name
      end

      def to_sql(query)
        name
      end
    end
  end
end
