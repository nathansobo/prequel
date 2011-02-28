require 'keep/relations/table'

module Keep
  module Relations
    class Table < Relation
      def create_table
        columns.tap do |columns| # bind to a local to bring inside of instance_eval
          DB.create_table(name) do
            columns.each do |c|
              if c.name == :id
                primary_key c.name, c.type
              else
                column c.name, c.type
              end
            end
          end
        end
      end
    end
  end
end