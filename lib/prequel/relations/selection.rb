module Prequel
  module Relations
    class Selection < Relation
      attr_reader :operand, :predicate
      delegate :get_table, :infer_join_columns, :tables, :to => :operand

      def initialize(operand, predicate)
        @operand = operand
        @predicate = resolve(predicate.to_predicate)
      end

      def create(attributes={})
        operand.create(predicate.enhance_attributes(attributes))
      end

      def create!(attributes={})
        operand.create!(predicate.enhance_attributes(attributes))
      end

      def find_or_create(attributes)
        enhanced_attributes = predicate.enhance_attributes(attributes)
        operand.find(enhanced_attributes) || operand.create(enhanced_attributes)
      end

      def new(attributes={})
        operand.new(predicate.enhance_attributes(attributes))
      end

      def columns
        operand.columns.map do |column|
          derive(column)
        end
      end

      def visit(query)
        operand.visit(query)
        query.add_condition(predicate.resolve_in_query(query))
      end

      derive_equality :predicate, :operand

      def pull_up_conditions
        Selection.new(operand.pull_up_conditions, predicate)
      end

      def extract_conditions
        new_operand, extracted_predicates = operand.extract_conditions
        [new_operand, extracted_predicates + [predicate]]
      end

      def wire_representation
        {
          'type' => "selection",
          'operand' => operand.wire_representation,
          'predicate' => predicate.wire_representation
        }
      end

      protected

      def operands
        [operand]
      end
    end
  end
end

