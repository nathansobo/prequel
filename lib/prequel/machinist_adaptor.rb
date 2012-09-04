require 'machinist'
require 'machinist/blueprint'
require 'machinist/lathe'

module Prequel
  class Blueprint < Machinist::Blueprint
    def make!(attributes = {})
      object = make(attributes)
      object.save!
    end

    def lathe_class
      Prequel::Lathe
    end
  end

  class Lathe < Machinist::Lathe
  end

  class Record
    extend Machinist::Machinable

    def self.blueprint_class
      Prequel::Blueprint
    end
  end

  module Relations
    class Selection
      def make!(attributes={})
        operand.make!(predicate.enhance_attributes(attributes))
      end

      def make(attributes={})
        operand.make(predicate.enhance_attributes(attributes))
      end
    end

    class Table
      delegate :make!, :make, :to => :tuple_class
    end

    class Relation
      delegate :make!, :make, :to => :operand
    end
  end
end
