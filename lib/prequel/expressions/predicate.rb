module Prequel
  module Expressions
    class Predicate
      extend EqualityDerivation

      attr_reader :left, :right
      def initialize(left, right)
        @left, @right = left, right
      end

      def &(other)
        And.new(self, other)
      end

      def |(other)
        Or.new(self, other)
      end

      def resolve_in_relations(relations)
        if new_left = convert_record_reference(relations)
          self.class.new(new_left, right.try(:id))
        else
          self.class.new(resolve_operand_in_relations(left, relations), resolve_operand_in_relations(right, relations))
        end
      end

      def resolve_operand_in_relations(operand, relations)
        operand.resolve_in_relations(relations).tap do |resolved|
          raise "Column #{operand.inspect} could not be found" if !operand.nil? && resolved.nil?
        end
      end

      def resolve_in_query(query)
        self.class.new(left.resolve_in_query(query), right.resolve_in_query(query))
      end

      def to_predicate
        self
      end

      derive_equality :type, :left, :right

      def to_sql
        maybe_parenthesize("#{left.to_sql} #{operator_sql} #{right.to_sql}")
      end

      def parenthesize?
        false
      end

      def maybe_parenthesize(s)
        if parenthesize?
          "(#{s})"
        else
          s
        end
      end

      def wire_representation
        {
          'type' => type.to_s,
          'leftOperand' => left.wire_representation,
          'rightOperand' => right.wire_representation
        }
      end

      protected

      def convert_record_reference(relations)
        return unless left.instance_of?(Symbol) && (right.is_a?(Record) || right.nil?)
        return if left.resolve_in_relations(relations)
        "#{left}_id".to_sym.resolve_in_relations(relations)
      end
    end
  end
end
