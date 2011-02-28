module Keep
  module Sql
    class Subquery < Query
      attr_reader :name

      def initialize(name)
        @name = name
        super()
      end

      def to_sql(query)
        ['(', sql_string(query), ') as ', name].join
      end

      # I suspect these methods need to delegate to the parent query.
      def add_literal(literal)
        raise NotImplementedError
      end

      def add_subquery(relation)
        raise NotImplementedError
      end
    end
  end
end
