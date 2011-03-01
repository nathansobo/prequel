require 'keep/relations/table'
require 'keep/expressions/column'

module Keep
  module Relations
    class Table < Relation
      def self.created_tables
        @created_tables ||= []
      end

      def self.drop_all_tables
        created_tables.each(&:drop_table)
      end

      delegate :created_tables, :to => 'self.class'
      def create_table
        DB.drop_table(name) if DB.table_exists?(name)
        columns.tap do |columns| # bind to a local to bring inside of instance_eval
          DB.create_table(name) do
            columns.each do |c|
              if c.name == :id
                primary_key c.name, c.schema_type
              else
                column c.name, c.schema_type
              end
            end
          end
        end

        created_tables.push(self)
      end

      def drop_table
        DB.drop_table(name)
      end
    end
  end

  module Expressions
    class Column
      def schema_type
        case type
          when :string
            String
          when :integer
            Integer
          else
            raise "Can't convert to a type suitable for Sequel migrations"
        end
      end
    end
  end
end